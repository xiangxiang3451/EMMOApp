import 'dart:convert';
import 'package:emotion_recognition/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:emotion_recognition/public_widgets/auth_widgets.dart';
import 'register_screen.dart'; 
import 'home_screen.dart'; // 确保导入主界面的类

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // 发送登录请求到 Flask 后端
    final response = await http.post(
      Uri.parse('$BackEndUrl/login'), // 本地 Flask 后端 URL
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // 登录成功
      print('登录成功');

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录成功')),
      );

      // 跳转到主界面
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // 确保 MainScreen 是你的主界面
        );
      });
    } else {
      // 登录失败
      print('登录失败: ${response.body}');

      // 显示失败提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败: ${response.body}')),
      );
    }
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
