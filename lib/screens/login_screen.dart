import 'package:flutter/material.dart';
import 'package:emotion_recognition/public_widgets/auth_widgets.dart'; 
import 'register_screen.dart'; // 导入注册页面

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    // 实现登录逻辑
    String email = _emailController.text;
    String password = _passwordController.text;

    // 调用登录服务 (可以与Firebase结合)
    print('Logging in with email: $email and password: $password');
    // TODO: Call your authentication service here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthInputField(
              labelText: '邮箱',
              controller: _emailController,
            ),
            const SizedBox(height: 16.0),
            AuthInputField(
              labelText: '密码',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            AuthButton(
              text: '登录',
              onPressed: _login,
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text('没有账号？注册'),
            ),
          ],
        ),
      ),
    );
  }
}
