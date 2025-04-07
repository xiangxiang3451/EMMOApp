import 'package:audioplayers/audioplayers.dart';
import 'package:emmo/services/authentication_service.dart';
import 'package:emmo/features/authentication/login_screen.dart';
import 'package:emmo/services/firebase_service.dart';
import 'package:emmo/services/gpt_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final AudioPlayer globalAudioPlayer = AudioPlayer(); // 全局 AudioPlayer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => globalAudioPlayer),
        Provider(create: (_) => FirebaseService()),
        Provider(create: (_) => GPTService()),
        Provider(create: (_) => AuthenticationService()),
        // 其他全局服务...
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      // 添加路由观察器以便调试
      navigatorObservers: [routeObserver],
    );
  }
}

// 路由观察器用于调试
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();