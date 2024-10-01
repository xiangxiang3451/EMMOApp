// lib/screens/emotion_analysis_screen.dart
import 'package:flutter/material.dart';

class EmotionAnalysisScreen extends StatelessWidget {
  const EmotionAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '实时情感分析',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Icon(Icons.face, size: 100, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              '这里将显示面部表情与语音情感分析的实时数据。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
