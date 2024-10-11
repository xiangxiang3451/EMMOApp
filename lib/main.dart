import 'package:emotion_recognition/models/theme_data.dart';
import 'package:emotion_recognition/services/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart'; // 导入登录页面

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // 创建主题通知器
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context); // 获取主题通知器

    return MaterialApp(
      title: 'Emotion Analysis App',
      theme: themeNotifier.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme, // 使用主题
      home: const LoginScreen(), // 启动时显示登录页面
    );
  }
}