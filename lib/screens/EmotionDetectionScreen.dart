import 'package:emotion_recognition/models/constants.dart';
import 'package:emotion_recognition/screens/emotion_analysis_screen.dart';
import 'package:emotion_recognition/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // 用于处理定时器
import 'package:camera/camera.dart'; // 摄像头插件
import 'package:http/http.dart' as http; // 用于API请求
import 'dart:convert'; // 用于解析JSON数据
import 'package:fl_chart/fl_chart.dart'; // 用于直方图展示

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
    detectionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        // **在这里也添加mounted检查**
        captureAndPredict();
      }
    });
    if (mounted) {
      // **检查页面是否挂载**
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

  // 构建直方图的组件
  Widget _buildBarChart(Map<String, double> probabilities) {
    return BarChart(
      BarChartData(
        barGroups: probabilities.entries.map((entry) {
          return BarChartGroupData(
            x: probabilities.keys.toList().indexOf(entry.key), // 根据情感标签设置X轴位置
            barRods: [
              BarChartRodData(
                toY: entry.value * 100, // 转换为百分比展示
                color: entry.value > 0.5
                    ? Colors.green
                    : Colors.orange, // 根据概率值动态改变颜色
                width: 30, // 设置柱子的宽度
                borderRadius: BorderRadius.circular(8), // 柱子的圆角
              ),
            ],
          );
        }).toList(),
        borderData: FlBorderData(show: false), // 隐藏边框
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // 为底部标题保留的空间
              getTitlesWidget: (double value, TitleMeta meta) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // 调整垂直间距
                  child: Text(
                    probabilities.keys.elementAt(value.toInt()), // 显示情感标签
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold), // 字体加粗
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text('${value.toInt()}%',
                    style: const TextStyle(fontSize: 12)); // 显示概率百分比
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false), // 隐藏网格线
      ),
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
              ? Container(
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

          // 实时更新的直方图，占据屏幕剩余的空间
          probabilities != null
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildBarChart(probabilities!),
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
