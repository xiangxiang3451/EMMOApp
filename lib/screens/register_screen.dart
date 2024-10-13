import 'dart:convert';
import 'package:emotion_recognition/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:emotion_recognition/public_widgets/auth_widgets.dart';
import 'login_screen.dart'; // 导入登录页面的类

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  bool _isCodeSent = false; // 追踪验证码是否已发送

  Future<void> _sendVerificationCode() async {
    String email = _emailController.text;
    
    // 发送验证码请求到 Flask 后端
    final response = await http.post(
      Uri.parse('$BackEndUrl/register'), // 后端发送验证码的 URL
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'password': _passwordController.text}), // 发送邮箱和密码
    );

    if (response.statusCode == 201) {
      // 验证码发送成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('验证码已发送，请检查您的邮箱')),

      );
      setState(() {
        _isCodeSent = true; // 更新状态
      });
    } else {
      // 验证码发送失败
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('验证码发送失败: ${response.body}')),
      );
    }
  }

  Future<void> _verifyRegistration() async {
    String email = _emailController.text;
    String verificationCode = _verificationCodeController.text;

    // 发送验证码验证请求到 Flask 后端
    final response = await http.post(
      Uri.parse('$BackEndUrl/verify_registration'), // 验证用户输入的验证码
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'code': verificationCode,
      }),
    );

    if (response.statusCode == 200) {
      // 验证成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('验证成功，注册完成！')),
      );

      // 解析响应并保存用户 ID
      // final responseData = jsonDecode(response.body);
      // User user = User(); // 获取单例
      // user.userId = responseData['user_id']; // 假设后端返回的用户 ID 字段为 'user_id'
      // user.email = email; // 可选：存储邮箱

      // 跳转到登录页面
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()), // 确保 LoginScreen 是你的登录页面
        );
      });
    } else {
      // 验证失败
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('验证失败: ${response.body}')),
      );
    }
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
            // 验证码输入框
            if (_isCodeSent) ...[
              AuthInputField(
                labelText: '验证码',
                controller: _verificationCodeController,
              ),
              const SizedBox(height: 16.0),
            ],
            AuthButton(
              text: _isCodeSent ? '验证并注册' : '发送验证码',
              onPressed: _isCodeSent ? _verifyRegistration : _sendVerificationCode,
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('已有账号？登录'),
            ),
          ],
        ),
      ),
    );
  }
}
