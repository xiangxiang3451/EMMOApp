import 'package:emotion_recognition/l10n/gen/app_localizations.dart';
import 'package:emotion_recognition/models/theme_data.dart';
import 'package:emotion_recognition/services/language_notifier.dart';
import 'package:emotion_recognition/services/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart'; // 导入登录页面

void main() {
  runApp(
   MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()), // 创建主题通知器
        ChangeNotifierProvider(create: (context) => LanguageNotifier()), // 创建语言通知器
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context); // 获取主题通知器
    final languageNotifier = Provider.of<LanguageNotifier>(context);//获取语言通知器

    return MaterialApp(
      title: 'Emotion Analysis App',
      locale: languageNotifier.locale, // 使用语言状态
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // 英语
        Locale('zh', ''), // 中文
      ],
      theme: themeNotifier.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme, // 使用主题
      home: const LoginScreen(), // 启动时显示登录页面
    );
  }
}