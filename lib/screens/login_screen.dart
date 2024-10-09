import 'dart:convert';
import 'package:emotion_recognition/models/constants.dart';
import 'package:emotion_recognition/screens/register_screen.dart';
import 'package:emotion_recognition/services/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart'; // 确保导入主界面

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
      // 解析响应并保存用户 ID 和头像 URL
      final responseData = jsonDecode(response.body);
      User user = User(); // 获取单例
      user.userId = responseData['user_id']; // 假设后端返回的用户 ID 字段为 'user_id'
      user.avatarUrl = responseData['avatar_url']; // 保存头像 URL
      print('Avatar URL: ${User().avatarUrl}');


      // 跳转到主界面
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false, // 这将移除所有的页面
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
            TextField(
              decoration: const InputDecoration(labelText: '邮箱'),
              controller: _emailController,
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(labelText: '密码'),
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('登录'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // 导航到注册界面
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: const Text('没有账号？注册'),
            ),
          ],
        ),
      ),
    );
  }
}
