// lib/models/call_model.dart
enum CallStatus {
  calling,
  ringing,
  answered,
  declined,
  ended,
  missed,
  busy,
}

enum CallType {
  audio,
  video,
}

class CallData {
  final String callId;
  final String callerId;
  final String receiverId;
  final String receiverName;
  final String callerName;
  final bool isVideoCall;
  final CallStatus status;
  final int createdAt;
  final int? answeredAt;
  final int? endedAt;
  final int? duration; // in seconds
  final String? endReason;

  CallData({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.receiverName,
    required this.callerName,
    required this.isVideoCall,
    required this.status,
    required this.createdAt,
    this.answeredAt,
    this.endedAt,
    this.duration,
    this.endReason,
  });

  factory CallData.fromMap(Map<String, dynamic> map) {
    return CallData(
      callId: map['callId'] ?? '',
      callerId: map['callerId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      callerName: map['callerName'] ?? '',
      isVideoCall: map['isVideoCall'] ?? false,
      status: _parseCallStatus(map['status']),
      createdAt: map['createdAt'] ?? 0,
      answeredAt: map['answeredAt'],
      endedAt: map['endedAt'],
      duration: map['duration'],
      endReason: map['endReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'callerName': callerName,
      'isVideoCall': isVideoCall,
      'status': status.name,
      'createdAt': createdAt,
      'answeredAt': answeredAt,
      'endedAt': endedAt,
      'duration': duration,
      'endReason': endReason,
    };
  }

  static CallStatus _parseCallStatus(dynamic statusValue) {
    if (statusValue is String) {
      try {
        return CallStatus.values.firstWhere(
              (status) => status.name == statusValue,
          orElse: () => CallStatus.calling,
        );
      } catch (e) {
        return CallStatus.calling;
      }
    }
    return CallStatus.calling;
  }

  // Get call type enum
  CallType get callType => isVideoCall ? CallType.video : CallType.audio;

  // Check if call is active
  bool get isActive => status == CallStatus.answered;

  // Check if call is ongoing
  bool get isOngoing => status == CallStatus.calling ||
      status == CallStatus.ringing ||
      status == CallStatus.answered;

  // Check if call has ended
  bool get hasEnded => status == CallStatus.ended ||
      status == CallStatus.declined ||
      status == CallStatus.missed;

  // Get formatted duration
  String getFormattedDuration() {
    if (duration == null) return '00:00';

    int minutes = duration! ~/ 60;
    int seconds = duration! % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get call duration in seconds
  int getCallDuration() {
    if (answeredAt != null && endedAt != null) {
      return ((endedAt! - answeredAt!) / 1000).round();
    }
    return 0;
  }

  // Get formatted date time
  String getFormattedDateTime() {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(createdAt);
    DateTime now = DateTime.now();

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.day == now.day - 1 &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // Get status display text
  String getStatusDisplayText() {
    switch (status) {
      case CallStatus.calling:
        return 'Calling...';
      case CallStatus.ringing:
        return 'Ringing...';
      case CallStatus.answered:
        return 'Connected';
      case CallStatus.declined:
        return 'Declined';
      case CallStatus.ended:
        return 'Ended';
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.busy:
        return 'Busy';
      default:
        return 'Unknown';
    }
  }

  // Get call type display text
  String getCallTypeDisplayText() {
    return isVideoCall ? 'Video Call' : 'Audio Call';
  }

  // Copy with method
  CallData copyWith({
    String? callId,
    String? callerId,
    String? receiverId,
    String? receiverName,
    String? callerName,
    bool? isVideoCall,
    CallStatus? status,
    int? createdAt,
    int? answeredAt,
    int? endedAt,
    int? duration,
    String? endReason,
  }) {
    return CallData(
      callId: callId ?? this.callId,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      callerName: callerName ?? this.callerName,
      isVideoCall: isVideoCall ?? this.isVideoCall,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      endReason: endReason ?? this.endReason,
    );
  }

  @override
  String toString() {
    return 'CallData(callId: $callId, callerId: $callerId, receiverId: $receiverId, status: ${status.name}, isVideoCall: $isVideoCall)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CallData && other.callId == callId;
  }

  @override
  int get hashCode => callId.hashCode;
}