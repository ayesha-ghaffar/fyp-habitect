// lib/services/chat_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/models/message_model.dart';
import 'package:fyp/models/chatroom_model.dart';
import 'package:fyp/models/user_model.dart'; // For participant names

class ChatService {
  final FirebaseDatabase _database = FirebaseDatabase.instance; // Correctly initialize here
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create or get existing chat room between two users
  Future<String> createChatRoom(String userId1, String userId2) async {
    String chatId = _generateChatId(userId1, userId2);
    DatabaseReference chatRef = _database.ref().child('chatRooms').child(chatId);

    // Check if chat room already exists
    DataSnapshot snapshot = await chatRef.get();

    if (!snapshot.exists) {
      // Create new chat room if it doesn't exist
      await chatRef.set({
        'chatRoomId': chatId, // Store ID within the document
        'participants': {
          userId1: true,
          userId2: true,
        },
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTime': ServerValue.timestamp,
        'unreadCount': 0, // Initialize unread count
      });
      print('New chat room created: $chatId');
    } else {
      print('Chat room already exists: $chatId');
    }

    return chatId;
  }

  // Generate consistent chat ID for two users (sorted to be unique)
  String _generateChatId(String userId1, String userId2) {
    List<String> users = [userId1, userId2];
    users.sort(); // Ensure consistent ordering regardless of input order
    return '${users[0]}_${users[1]}';
  }

  // Send message to a chat room
  Future<void> sendMessage(String chatRoomId, String messageContent, String receiverId) async {
    String? senderId = _auth.currentUser?.uid;
    if (senderId == null) throw Exception('User not authenticated to send message.');

    DatabaseReference messagesRef = _database.ref()
        .child('chatRooms')
        .child(chatRoomId)
        .child('messages')
        .push(); // Generates unique message ID

    Message newMessage = Message(
      messageId: messagesRef.key!, // Use the generated key as messageId
      senderId: senderId,
      receiverId: receiverId,
      message: messageContent,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isRead: false,
    );

    await messagesRef.set(newMessage.toMap());
    print('Message sent in chat ${chatRoomId}: ${newMessage.message}');

    // Update last message details in the chat room
    await _database.ref().child('chatRooms').child(chatRoomId).update({
      'lastMessage': messageContent,
      'lastMessageSenderId': senderId,
      'lastMessageTime': ServerValue.timestamp,
      // You might increment unreadCount for the receiver here if needed,
      // but handling unread counts robustly often requires more complex logic
      // (e.g., per-user unread counts).
    });

    // Send notification to receiver (requires FCM implementation)
    await _sendNotification(receiverId, senderId, messageContent);
  }

  // Stream to listen to messages in a specific chat room
  Stream<List<Message>> getMessages(String chatRoomId) {
    return _database.ref()
        .child('chatRooms')
        .child(chatRoomId)
        .child('messages')
        .orderByChild('timestamp') // Order by timestamp
        .onValue
        .map((event) {
      List<Message> messages = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          // Ensure key is used as messageId
          messages.add(Message.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
      return messages.reversed.toList(); // Display latest messages at the bottom (usually)
    });
  }

  // Stream to get all chat rooms for a specific user
  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _database.ref()
        .child('chatRooms')
        .orderByChild('lastMessageTime')
        .onValue
        .map((event) {
      List<ChatRoom> chatRooms = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          Map<String, dynamic> chatData = Map<String, dynamic>.from(value);
          // Check if the current user is a participant in this chat room
          if (chatData['participants'] != null &&
              chatData['participants'][userId] == true) {
            chatRooms.add(ChatRoom.fromMap(chatData)); // Key is implicitly chatRoomId
          }
        });
      }
      // Sort to show most recent chats first (assuming 'lastMessageTime' is reliable)
      chatRooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return chatRooms;
    });
  }

  // Mark messages as read by a specific user in a chat room
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    DatabaseReference messagesRef = _database.ref()
        .child('chatRooms')
        .child(chatRoomId)
        .child('messages');

    DataSnapshot snapshot = await messagesRef.get();
    if (snapshot.value != null) {
      Map<dynamic, dynamic> messages = snapshot.value as Map<dynamic, dynamic>;
      Map<String, dynamic> updates = {};

      messages.forEach((key, value) {
        // Only mark messages as read that were sent TO the current user and are not yet read
        if (value['receiverId'] == userId && value['senderId'] != userId && (value['isRead'] == false || value['isRead'] == null)) {
          updates['${key}/isRead'] = true;
        }
      });

      if (updates.isNotEmpty) {
        await messagesRef.update(updates);
        print('Messages in chat ${chatRoomId} marked as read by ${userId}');
      }
    }
  }

  // FIX: Added deleteChatRoom method, using _database
  Future<void> deleteChatRoom(String chatRoomId) async {
    await _database.ref().child('chatRooms').child(chatRoomId).remove();
    print('Chat room ${chatRoomId} deleted.');
  }

  // Send notification (This needs actual FCM implementation for real push notifications)
  Future<void> _sendNotification(String receiverId, String senderId, String message) async {
    // This is a simplified Firebase database entry for internal notification tracking.
    // For actual push notifications, you will need to integrate Firebase Cloud Messaging (FCM).
    // This typically involves:
    // 1. Getting the receiver's FCM token from their UserModel data.
    // 2. Sending a message to that token via FCM (usually from a backend/Cloud Function)
    // 3. Handling the notification on the client side when the app is in foreground/background/terminated.
    await _database.ref().child('notifications').child(receiverId).push().set({
      'type': 'chat_message',
      'senderId': senderId,
      'message': message,
      'timestamp': ServerValue.timestamp,
      'isRead': false,
    });
    print('Firebase notification entry created for message to ${receiverId}');
  }

  // Cleanup (if any listeners were manually set up, though Streams handle their own disposal)
  void dispose() {
    // No explicit disposal needed for Firebase references or streams managed by .onValue
  }
}