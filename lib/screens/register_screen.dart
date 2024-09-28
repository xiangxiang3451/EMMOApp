import 'package:flutter/material.dart';
import 'package:emotion_recognition/public_widgets/auth_widgets.dart'; 

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() {
    // 实现注册逻辑
    String email = _emailController.text;
    String password = _passwordController.text;

    // 调用注册服务 (可以与Firebase结合)
    print('Registering with email: $email and password: $password');
    // TODO: Call your authentication service here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
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
              text: '注册',
              onPressed: _register,
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 返回登录页面
              },
              child: const Text('已有账号？登录'),
            ),
          ],
        ),
      ),
    );
  }
}
