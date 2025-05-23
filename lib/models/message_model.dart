// lib/models/message_model.dart
class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final int timestamp;
  final bool isRead; // New field for read status

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false, // Default to false
  });

  factory Message.fromMap(Map<String, dynamic> map, String messageId) {
    return Message(
      messageId: messageId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      isRead: map['isRead'] ?? false, // Handle new field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead, // Include new field
    };
  }

  String getFormattedTime() {
    DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();

    // Check if it's today
    if (messageTime.day == now.day && messageTime.month == now.month && messageTime.year == now.year) {
      return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    }
    // Check if it's yesterday
    else if (messageTime.day == now.day - 1 && messageTime.month == now.month && messageTime.year == now.year) {
      return 'Yesterday ${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    }
    // Otherwise, show full date
    else {
      return '${messageTime.day.toString().padLeft(2, '0')}/${messageTime.month.toString().padLeft(2, '0')}/${messageTime.year % 100} ${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Message copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? message,
    int? timestamp,
    bool? isRead,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'Message(messageId: $messageId, senderId: $senderId, receiverId: $receiverId, message: $message, timestamp: $timestamp, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.messageId == messageId;
  }

  @override
  int get hashCode => messageId.hashCode;
}