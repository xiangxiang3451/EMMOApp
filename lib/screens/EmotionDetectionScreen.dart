import 'package:emotion_recognition/models/constants.dart';
import 'package:emotion_recognition/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // 用于处理定时器
import 'package:camera/camera.dart'; // 摄像头插件
import 'package:http/http.dart' as http; // 用于API请求
import 'dart:convert'; // 用于解析JSON数据
import 'package:fl_chart/fl_chart.dart'; // 用于饼图展示

class EmotionDetectionScreen extends StatefulWidget {
  const EmotionDetectionScreen({super.key});

  @override
  _EmotionDetectionScreenState createState() => _EmotionDetectionScreenState();
}

class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isDetecting = false;
  String detectedEmotion = "None";
  Map<String, double>? probabilities;
  Timer? detectionTimer;

  // 定义7种不同的颜色
  final List<Color> emotionColors = [
    Colors.red, // 第一种颜色
    Colors.blue, // 第二种颜色
    Colors.green, // 第三种颜色
    Colors.orange, // 第四种颜色
    Colors.purple, // 第五种颜色
    Colors.yellow, // 第六种颜色
    Colors.pink, // 第七种颜色
  ];

  @override
  void initState() {
    super.initState();
    // 初始化摄像头
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras != null && cameras!.isNotEmpty) {
        controller = CameraController(cameras![0], ResolutionPreset.medium);
        controller!.initialize().then((_) {
          if (!mounted) return;
          setState(() {});
        });
      }
    });
  }

  // 捕获图像并发送到API进行情感分析
  Future<void> captureAndPredict() async {
    if (controller == null || !controller!.value.isInitialized) return;

    try {
      // 拍照
      final image = await controller!.takePicture();
      final imagePath = image.path;

      // 调用Flask API
      final url = Uri.parse('$BackEndUrl/predict_emotion_video');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('video', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decodedResponse =
            json.decode(response.body) as Map<String, dynamic>;

        setState(() {
          // 找出情感概率最大的标签
          detectedEmotion = decodedResponse.keys.firstWhere((key) =>
              decodedResponse[key] ==
              decodedResponse.values
                  .reduce((curr, next) => curr > next ? curr : next));
          // 保存概率列表
          probabilities = decodedResponse
              .map((key, value) => MapEntry(key, value as double));
        });
      } else {
        setState(() {
          detectedEmotion = "Error in prediction";
        });
      }
    } catch (e) {
      setState(() {
        detectedEmotion = "Error: $e";
      });
    }
  }

  // 实时情感检测
  void startEmotionDetection() {
    detectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        captureAndPredict();
      }
    });
    if (mounted) {
      setState(() {
        isDetecting = true;
      });
    }
  }

  // 停止情感检测并关闭摄像头
  void stopEmotionDetection() {
    if (detectionTimer != null && detectionTimer!.isActive) {
      detectionTimer!.cancel();
    }

    // 释放摄像头资源
    if (controller != null) {
      controller!.dispose();
      controller = null; // 清空controller
      isDetecting = false;
    }

    // 停止检测后返回上一个页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    stopEmotionDetection(); // 确保页面退出时停止检测并释放摄像头
    super.dispose();
  }

  // 构建饼图的组件
  Widget _buildPieChart(Map<String, double> probabilities) {
    return PieChart(
      PieChartData(
        sections: probabilities.entries.map((entry) {
          int index = probabilities.keys.toList().indexOf(entry.key);
          return PieChartSectionData(
            color: emotionColors[index % emotionColors.length], // 使用不同颜色
            value: entry.value * 100, // 转换为百分比展示
            title: '', // 不在饼图上显示百分比
            radius: 60, // 饼图扇形的半径
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        borderData: FlBorderData(show: false), // 隐藏边框
        sectionsSpace: 2, // 扇形之间的空隙
        centerSpaceRadius: 40, // 饼图中心的空白区域大小
      ),
    );
  }

  // 构建图例
  Widget _buildLegend(Map<String, double> probabilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: probabilities.entries.map((entry) {
        int index = probabilities.keys.toList().indexOf(entry.key);
        final color = emotionColors[index % emotionColors.length];
        return Row(
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color, // 设置图例的颜色
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.key, // 显示情感名称
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时情感分析'),
        leading: Container(), // 去掉左上角的默认返回按钮
      ),
      body: Column(
        children: <Widget>[
          // 调整摄像头预览的大小，让它占用较小的区域
          controller != null && controller!.value.isInitialized
              ? SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.35, // 让摄像头预览占用屏幕的 35%
                  child: AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: CameraPreview(controller!),
                  ),
                )
              : const CircularProgressIndicator(),

          const SizedBox(height: 20),

          // 显示预测到的情感
          Text(
            '当前情感: $detectedEmotion',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 饼图和图例展示
          probabilities != null
              ? Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 饼图
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildPieChart(probabilities!),
                        ),
                      ),
                      // 图例
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9.0),
                          child: _buildLegend(probabilities!),
                        ),
                      ),
                    ],
                  ),
                )
              : const Text('等待检测...'),

          const SizedBox(height: 20),

          // 新添加的按钮，点击后开始或停止情绪检测
          ElevatedButton(
            onPressed: () {
              if (isDetecting) {
                stopEmotionDetection();
              } else {
                startEmotionDetection();
              }
            },
            child: Text(isDetecting ? '停止情绪检测' : '开始情绪检测'),
          ),
        ],
      ),

      // 使用FloatingActionButton悬浮按钮
      floatingActionButton: FloatingActionButton(
        onPressed: isDetecting ? stopEmotionDetection : startEmotionDetection,
        child: Icon(isDetecting ? Icons.stop : Icons.play_arrow),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // 将按钮定位在右下角
    );
  }
}
