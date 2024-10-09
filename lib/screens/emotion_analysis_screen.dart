import 'package:emotion_recognition/screens/EmotionDetectionScreen.dart';
import 'package:flutter/material.dart';

class EmotionAnalysisScreen extends StatefulWidget {
  const EmotionAnalysisScreen({super.key});

  @override
  _EmotionAnalysisScreenState createState() => _EmotionAnalysisScreenState();
}

class _EmotionAnalysisScreenState extends State<EmotionAnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('情感分析主页'),
        automaticallyImplyLeading: false, // 禁用默认的返回按钮
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),

          // 其他功能按钮
          ElevatedButton(
            onPressed: () {
              // 添加你现有的其他功能
            },
            child: const Text('其他功能 1'),
          ),
          ElevatedButton(
            onPressed: () {
              // 添加你现有的其他功能
            },
            child: const Text('其他功能 2'),
          ),

          const SizedBox(height: 20),

          // 跳转到情绪检测页面的按钮
          ElevatedButton(
            onPressed: () {
              // 跳转到情绪检测页面
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EmotionDetectionScreen()),
              );
            },
            child: const Text('进入情绪检测'),
          ),
        ],
      ),
    );
  }
}
