import 'package:emotion_recognition/screens/home_screen.dart';
import 'package:flutter/material.dart';
// import 'screens/login_screen.dart'; // 导入登录页面

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emotion Analysis App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // 启动时显示登录页面
    );
  }
}
