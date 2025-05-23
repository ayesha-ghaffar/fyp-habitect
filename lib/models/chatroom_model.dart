// lib/models/chatroom_model.dart
class ChatRoom {
  final String chatRoomId;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSenderId;
  final int lastMessageTime;
  final int unreadCount; // Added for read receipts in chat list

  ChatRoom({
    required this.chatRoomId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    required this.unreadCount, // Initialize unreadCount
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      chatRoomId: map['chatRoomId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? 0,
      unreadCount: map['unreadCount'] ?? 0, // Parse unreadCount
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount, // Include unreadCount
    };
  }

  // Helper method to get the other participant's ID
  String getOtherUserId(String currentUserId) {
    return participants.firstWhere((uid) => uid != currentUserId, orElse: () => '');
  }

  // Helper method to get formatted last message time for display
  String getFormattedTime() {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(lastMessageTime);
    DateTime now = DateTime.now();

    // If today, show only time
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    // If yesterday, show "Yesterday"
    else if (dateTime.day == now.day - 1 &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Yesterday';
    }
    // Otherwise, show full date
    else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }
  }

  // copyWith method to create a new instance with updated values (useful for immutability)
  ChatRoom copyWith({
    String? chatRoomId,
    List<String>? participants,
    String? lastMessage,
    String? lastMessageSenderId,
    int? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatRoom(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  String toString() {
    return 'ChatRoom(chatRoomId: $chatRoomId, participants: $participants, lastMessage: $lastMessage, lastMessageSenderId: $lastMessageSenderId, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoom && chatRoomId == other.chatRoomId;
  }

  @override
  int get hashCode => chatRoomId.hashCode;
}