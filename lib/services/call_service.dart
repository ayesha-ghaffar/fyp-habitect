// lib/services/call_service.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart'; // For @required or other Flutter annotations
import 'package:permission_handler/permission_handler.dart';

class CallService {
  late RtcEngine _engine;
  String? _appId; // Store Agora App ID
  String? _token; // Store Agora Token
  String? _channelId; // Store channel ID

  // Callbacks
  Function(int uid, int elapsed)? onJoinChannelSuccess;
  Function(int uid, int elapsed)? onUserJoined;
  Function(int uid, UserOfflineReasonType reason)? onUserOffline;
  Function(String reason, int errorCode)? onCallError;
  Function(int uid, int elapsed)? onLeaveChannel;
  Function(RtcConnection connection, LocalVideoStats stats)? onLocalVideoStats; // Updated signature
  Function(RtcConnection connection, RemoteVideoStats stats)? onRemoteVideoStats;
  Function(RtcConnection connection, LocalAudioStats stats)? onLocalAudioStats;
  Function(RtcConnection connection, RemoteAudioStats stats)? onRemoteAudioStats;

  CallService() {
    _appId = const String.fromEnvironment('AGORA_APP_ID'); // Get from environment variables or config
    if (_appId!.isEmpty) {
      debugPrint('AGORA_APP_ID is not set in environment variables.');
      // Handle this error appropriately in production
    }
  }

  Future<void> initializeAgora() async {
    if (_appId == null || _appId!.isEmpty) {
      debugPrint('Agora App ID is not available. Cannot initialize Agora engine.');
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: _appId!,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _addAgoraEventHandlers();

    // Enable video and audio
    await _engine.enableVideo();
    await _engine.enableAudio();
    // The client role is now only set in the joinChannel method via ChannelMediaOptions.
  }

  void _addAgoraEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('onJoinChannelSuccess: ${connection.localUid}, $elapsed');
          onJoinChannelSuccess?.call(connection.localUid ?? 0, elapsed);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('onUserJoined: $remoteUid, $elapsed');
          onUserJoined?.call(remoteUid, elapsed);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('onUserOffline: $remoteUid, $reason');
          onUserOffline?.call(remoteUid, reason);
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('onLeaveChannel: ${connection.localUid}, ${stats.duration}');
          onLeaveChannel?.call(connection.localUid ?? 0, stats.duration ?? 0);
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('onError: $err, $msg');
          onCallError?.call(msg, err.index);
        },
        onLocalVideoStats: (RtcConnection connection, LocalVideoStats stats) {
          debugPrint('Local video stats: ${stats.sentBitrate}');
          onLocalVideoStats?.call(connection, stats);
        },
        onRemoteVideoStats: (RtcConnection connection, RemoteVideoStats stats) {
          debugPrint('Remote video stats for uid: ${stats.uid}, ${stats.receivedBitrate}');
          onRemoteVideoStats?.call(connection, stats);
        },
        onLocalAudioStats: (RtcConnection connection, LocalAudioStats stats) {
          debugPrint('Local audio stats: ${stats.numChannels}');
          onLocalAudioStats?.call(connection, stats);
        },
        onRemoteAudioStats: (RtcConnection connection, RemoteAudioStats stats) {
          debugPrint('Remote audio stats for uid: ${stats.uid}, ${stats.numChannels}');
          onRemoteAudioStats?.call(connection, stats);
        },
      ),
    );
  }

  Future<void> joinChannel({
    required String channelId,
    String? token, // Token is optional for testing, but required for production
    int? uid, // Optional UID for a specific user, Agora assigns if null
  }) async {
    _channelId = channelId;
    _token = token; // Store the token
    await [Permission.microphone, Permission.camera].request();

    await _engine.joinChannel(
      token: _token ?? '', // Handled nullable token
      channelId: _channelId!,
      uid: uid ?? 0, // Pass 0 for Agora to assign UID
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster, // This is where the role is set
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
    debugPrint('Left channel $_channelId');
    _channelId = null;
    _token = null;
  }

  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }

  Future<void> toggleMuteAudio(bool mute) async {
    await _engine.muteLocalAudioStream(mute);
  }

  Future<void> toggleMuteVideo(bool mute) async {
    await _engine.muteLocalVideoStream(mute);
  }

  // Removed the setClientRole method entirely as it's typically set
  // during joinChannel for Agora RTC Engine 6.x.
  /*
  Future<void> setClientRole(ClientRoleType role) async {
    await _engine.setClientRole(
      role,
      const ClientRoleOptions(),
    );
  }
  */

  Future<void> dispose() async {
    debugPrint('Disposing Agora engine');
    await _engine.leaveChannel();
    await _engine.release();
  }
}