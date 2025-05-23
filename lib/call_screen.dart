// call_screen.dart
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:fyp/services/call_service.dart';
import 'dart:async';

class CallScreen extends StatefulWidget {
  final String callId;
  final bool isVideoCall;
  final bool isIncoming;
  final String otherUserName;
  final String otherUserId;

  const CallScreen({
    Key? key,
    required this.callId,
    required this.isVideoCall,
    required this.isIncoming,
    required this.otherUserName,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();

  bool _muted = false;
  bool _videoPaused = false;
  bool _speakerEnabled = false;
  bool _callConnected = false;
  int? _remoteUid;

  Timer? _callTimer;
  int _callDuration = 0;

  StreamSubscription<CallData?>? _callSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _listenToCallStatus();
  }

  Future<void> _initializeCall() async {
    // Request permissions
    bool permissionsGranted = await _callService.requestPermissions(widget.isVideoCall);
    if (!permissionsGranted) {
      _showPermissionDeniedDialog();
      return;
    }

    // Initialize Agora
    await _callService.initializeAgora();

    // Set event handlers
    _callService.setEventHandlers(
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          _remoteUid = remoteUid;
          _callConnected = true;
        });
        _startCallTimer();
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        setState(() {
          _remoteUid = null;
          _callConnected = false;
        });
        _endCall();
      },
    );

    // If incoming call, wait for user to answer
    if (!widget.isIncoming) {
      await _joinCall();
    }
  }

  void _listenToCallStatus() {
    _callSubscription = _callService.listenToCall(widget.callId).listen((callData) {
      if (callData != null) {
        switch (callData.status) {
          case 'answered':
            if (!_callConnected) {
              _joinCall();
            }
            break;
          case 'declined':
          case 'ended':
            _endCall();
            break;
        }
      }
    });
  }

  Future<void> _joinCall() async {
    int uid = int.parse(widget.otherUserId.hashCode.toString().substring(0, 8));
    await _callService.joinChannel(
      widget.callId,
      uid,
      isVideoCall: widget.isVideoCall,
    );
  }

  Future<void> _answerCall() async {
    await _callService.answerCall(widget.callId);
    await _joinCall();
  }

  Future<void> _declineCall() async {
    await _callService.declineCall(widget.callId);
    Navigator.pop(context);
  }

  Future<void> _endCall() async {
    _callTimer?.cancel();
    await _callService.endCall(widget.callId);
    await _callService.leaveChannel();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _callService.muteAudio(_muted);
  }

  void _toggleVideo() {
    if (widget.isVideoCall) {
      setState(() {
        _videoPaused = !_videoPaused;
      });
      _callService.muteVideo(_videoPaused);
    }
  }

  void _switchCamera() {
    if (widget.isVideoCall) {
      _callService.switchCamera();
    }
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(
          'This app needs ${widget.isVideoCall ? 'camera and ' : ''}microphone permissions to make calls.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video views
            if (widget.isVideoCall) _buildVideoViews(),

            // Audio call UI
            if (!widget.isVideoCall) _buildAudioCallUI(),

            // Top bar with user info and call duration
            _buildTopBar(),

            // Bottom controls
            _buildBottomControls(),

            // Incoming call overlay
            if (widget.isIncoming && !_callConnected) _buildIncomingCallOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoViews() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Remote video (full screen)
              _remoteUid != null
                  ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _callService.engine,
                  canvas: VideoCanvas(uid: _remoteUid),
                   connection: RtcConnection(channelId: widget.callId),
                ),
              )
                  : Container(
                color: Colors.grey[800],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: Text(
                          widget.otherUserName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.otherUserName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _callConnected ? 'Connected' : 'Connecting...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Local video (small window)
              if (!_videoPaused)
                Positioned(
                  top: 50,
                  right: 20,
                  child: SizedBox(
                    width: 120,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _callService.engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCallUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            child: Text(
              widget.otherUserName[0].toUpperCase(),
              style: const TextStyle(fontSize: 50),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.otherUserName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _callConnected ? 'Connected' : 'Connecting...',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_callConnected)
              Text(
                _formatDuration(_callDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const SizedBox(),

            if (widget.isVideoCall)
              IconButton(
                onPressed: _switchCamera,
                icon: const Icon(
                  Icons.switch_camera,
                  color: Colors.white,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute button
            _buildControlButton(
              icon: _muted ? Icons.mic_off : Icons.mic,
              onPressed: _toggleMute,
              backgroundColor: _muted ? Colors.red : Colors.white24,
            ),

            // Video toggle (only for video calls)
            if (widget.isVideoCall)
              _buildControlButton(
                icon: _videoPaused ? Icons.videocam_off : Icons.videocam,
                onPressed: _toggleVideo,
                backgroundColor: _videoPaused ? Colors.red : Colors.white24,
              ),

            // End call button
            _buildControlButton(
              icon: Icons.call_end,
              onPressed: _endCall,
              backgroundColor: Colors.red,
              size: 60,
            ),

            // Speaker button (audio call only)
            if (!widget.isVideoCall)
              _buildControlButton(
                icon: _speakerEnabled ? Icons.volume_up : Icons.volume_down,
                onPressed: () {
                  setState(() {
                    _speakerEnabled = !_speakerEnabled;
                  });
                  // Implement speaker toggle
                },
                backgroundColor: _speakerEnabled ? Colors.blue : Colors.white24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.white24,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  Widget _buildIncomingCallOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              child: Text(
                widget.otherUserName[0].toUpperCase(),
                style: const TextStyle(fontSize: 50),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Incoming ${widget.isVideoCall ? 'video' : 'audio'} call...',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline button
                GestureDetector(
                  onTap: _declineCall,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),

                // Answer button
                GestureDetector(
                  onTap: _answerCall,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isVideoCall ? Icons.videocam : Icons.call,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _callSubscription?.cancel();
    _callService.dispose();
    super.dispose();
  }
}