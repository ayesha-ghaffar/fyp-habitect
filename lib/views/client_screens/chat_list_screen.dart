import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fyp/services/chat_service.dart';
import 'package:fyp/views/client_screens/chat_screen.dart';
import 'package:fyp/models/chatroom_model.dart';
import 'package:fyp/services/user_service.dart';
import 'package:fyp/models/user_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  late UserService _userService;
  String? _currentUserId;

  // Theme colors
  static const Color primaryGreen = Color(0xFF6B8E23);
  static const Color lightGreen = Color(0xFF8FBC8F);
  static const Color darkGreen = Color(0xFF556B2F);

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initializing UserService here, after context is available
    _userService = UserService();
  }

  // Function to get current user's userType
  Future<String> getUserType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'unknown';

    try {
      final snapshot = await FirebaseDatabase.instance.ref('users/$uid').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data['userType'] ?? 'unknown';
      }
    } catch (e) {
      print('Error getting user type: $e');
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementing search functionality
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: _currentUserId == null
          ? const Center(child: Text('Please log in to view chats'))
          : StreamBuilder<List<ChatRoom>>(
        stream: _chatService.getUserChatRooms(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            print('Error fetching chat rooms: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          List<ChatRoom> chatRooms = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              ChatRoom chatRoom = chatRooms[index];
              return _buildChatTile(chatRoom);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String myType = await getUserType();
          String otherType = myType == 'client' ? 'architect' : 'client';
          _showUserList(otherType);
        },
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: lightGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: primaryGreen.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 22,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with architects or clients',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              String myType = await getUserType();
              String otherType = myType == 'client' ? 'architect' : 'client';
              _showUserList(otherType);
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Start New Chat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatRoom chatRoom) {
    String otherUserId = chatRoom.getOtherUserId(_currentUserId!);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<UserModel?>(
        future: _userService.getUserProfile(otherUserId),
        builder: (context, userSnapshot) {
          UserModel? userInfo = userSnapshot.data;

          String userName = userInfo?.name ?? 'Unknown User';
          String userImage = userInfo?.avatarUrl ?? '';
          bool isOnline = userInfo?.isOnline ?? false;
          String otherUserType = userInfo?.userType.name ?? 'unknown';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOnline ? primaryGreen : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: lightGreen.withOpacity(0.2),
                    backgroundImage: userImage.isNotEmpty
                        ? NetworkImage(userImage)
                        : null,
                    child: userImage.isEmpty
                        ? Text(
                      userName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    )
                        : null,
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  chatRoom.getFormattedTime(),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: otherUserType == 'architect' ? primaryGreen : lightGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    otherUserType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  chatRoom.lastMessage.isEmpty
                      ? 'No messages yet'
                      : chatRoom.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (chatRoom.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Text(
                      '${chatRoom.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteChatRoom(chatRoom.chatRoomId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Chat'),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    otherUserId: otherUserId,
                    otherUserName: userName,
                    otherUserType: otherUserType, // Pass the fetched type
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();

    Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.search, color: primaryGreen),
            const SizedBox(width: 8),
            const Text(
              'Search Chats',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search by name or message...',
            prefixIcon: Icon(Icons.search, color: primaryGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryGreen, width: 2),
            ),
          ),
          onChanged: (value) {
            // Implement search logic
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: primaryGreen),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Updated _showNewChatDialog to use current user's type
  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.chat, color: primaryGreen),
            const SizedBox(width: 8),
            const Text(
              'Start New Chat',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.architecture, color: primaryGreen),
                    ),
                    title: const Text(
                      'Find Architects',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showUserList('architect');
                    },
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lightGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person, color: lightGreen),
                    ),
                    title: const Text(
                      'Find Clients',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showUserList('client');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: primaryGreen),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUserList(String userType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              userType == 'architect' ? Icons.architecture : Icons.person,
              color: primaryGreen,
            ),
            const SizedBox(width: 8),
            Text(
              'Select ${userType.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<List<UserModel>>(
            stream: _userService.getUsersByType(UserType.values.firstWhere((e) => e.name == userType)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryGreen),
                );
              }

              if (snapshot.hasError) {
                print('Error fetching user list stream: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No $userType found.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              List<UserModel> users = snapshot.data!;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserModel user = users[index];
                  String userId = user.uid;
                  String userName = user.name;
                  String userAvatar = user.avatarUrl;
                  bool isOnline = user.isOnline;

                  // Don't show current user in the list
                  if (userId == _currentUserId) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: lightGreen.withOpacity(0.2),
                            backgroundImage: userAvatar.isNotEmpty
                                ? NetworkImage(userAvatar)
                                : null,
                            child: userAvatar.isEmpty
                                ? Text(
                              userName[0].toUpperCase(),
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : null,
                          ),
                          if (isOnline)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: isOnline ? primaryGreen : Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context); // Pop user list dialog
                        String chatId = await _chatService.createChatRoom(
                          _currentUserId!,
                          userId, // Use the actual user ID
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              otherUserId: userId,
                              otherUserName: userName,
                              otherUserType: user.userType.name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: primaryGreen),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _deleteChatRoom(String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text(
              'Delete Chat',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this chat? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Pop confirmation dialog
              try {
                await _chatService.deleteChatRoom(chatId); // Call delete method
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Chat deleted successfully'),
                    backgroundColor: primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } catch (e) {
                print("Error deleting chat: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete chat: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}