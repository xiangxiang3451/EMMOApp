import 'package:emmo/authentication/authentication_service.dart';
import 'package:emmo/screens/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String _statusMessage = '';
  bool _isCountingDown = false; // Whether the countdown is ongoing
  int _countdownTime = 60; // Countdown time

  // Send verification code
  Future<void> _sendVerificationCode() async {
    String email = _emailController.text;
    bool success = await AuthenticationService.sendVerificationCode(email);
    setState(() {
      _statusMessage = success ? 'Verification code sent to $email' : 'Failed to send verification code. Please check the email address or try again later.';
    });

    if (success) {
      // Start countdown
      setState(() {
        _isCountingDown = true;
      });

      // Start the countdown
      for (int i = 0; i < _countdownTime; i++) {
        if (!_isCountingDown) break;
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _countdownTime -= 1;
        });
      }

      // Reset button after countdown ends
      if (_isCountingDown) {
        setState(() {
          _isCountingDown = false;
          _countdownTime = 60;
        });
      }
    }
  }

  // Verify the code
  Future<void> _verifyCode() async {
    String email = _emailController.text;
    String code = _codeController.text;
    bool isVerified = await AuthenticationService.verifyCode(email, code);
    setState(() {
      _statusMessage = isVerified ? 'Verification successful!' : 'Incorrect verification code. Please try again.';
    });

    if (isVerified) {
      // After successful verification, navigate to the main screen
      AuthenticationService.currentUserEmail=email;  // 获取当前登录用户的 email
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }

    // Show status message as SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_statusMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Use Row to place the button and input field in the same line
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Enter verification code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _isCountingDown ? null : _sendVerificationCode, // Disable button during countdown
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(_isCountingDown ? '$_countdownTime s' : 'Get Code'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _verifyCode,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
