import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:fyp/services/auth_service.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isEmailVerified = false;
  String? _resendMessage;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (!_isEmailVerified) {

      _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        setState(() {
          _isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
        });
        if (_isEmailVerified) {
          _timer?.cancel();
          _showVerifiedDialogAndNavigate();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _showVerifiedDialogAndNavigate() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Email Verified!"),
          content: Text("Your email has been successfully verified. You can now log in."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  void _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _resendMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    String? error = await authService.resendVerificationEmail();

    setState(() {
      _isResending = false;
      if (error == null) {
        _resendMessage = "Verification email sent successfully! Check your inbox.";
      } else {
        _resendMessage = "Failed to resend email: $error";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Verify Your Email'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _isEmailVerified ? Icons.check_circle_outline : Icons.email_outlined,
              size: 100,
              color: _isEmailVerified ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _isEmailVerified
                  ? "Your email has been verified!"
                  : "A verification link has been sent to your email address.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEmailVerified
                  ? "You can now proceed to login."
                  : "Please check your inbox (and spam folder) and click the link to verify your email. We automatically check every few seconds.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            if (!_isEmailVerified)
              ElevatedButton(
                onPressed: _isResending ? null : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isResending
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Resend Verification Email'),
              ),
            if (_resendMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _resendMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _resendMessage!.contains("successfully") ? Colors.green : Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Go to Login',
                style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}