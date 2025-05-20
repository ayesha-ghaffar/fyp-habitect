import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  void _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (!EmailValidator.validate(email)) {
      setState(() => _message = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _message = 'Password reset link sent to your email.');
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Habitect',
          style: TextStyle(
            fontFamily: 'Judson',
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(// Title
                child: Text('Recover Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Instructions
              Center(
                child: Text(
                  'Please enter your registered email address. We\'ll send you a link to reset your password.',
                  style: TextStyle(fontSize: 14, color: Color(0xFFE2725B)), textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Email Field
              const Text('Email Address', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 32),

              // Send Reset Link Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E23),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send Reset Link', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),

              // Message
              if (_message != null)
                Center(
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _message == 'Password reset link sent to your email.'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
