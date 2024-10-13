import 'package:emotion_recognition/models/constants.dart';
import 'package:emotion_recognition/services/user.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart'; // 使用 fl_chart 构建饼状图
import 'package:intl/intl.dart'; // 引入用来格式化日期的库

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> emotionHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmotionHistory();
  }

  // 从Flask API获取当前用户的情感历史数据
  Future<void> fetchEmotionHistory() async {
    // 从单例中获取当前用户ID
    String? userId = User().userId;

    // 构造 POST 请求
    final response = await http.post(
      Uri.parse('$BackEndUrl/emotion_history'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        emotionHistory = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load emotion history');
    }
  }

  // 点击每个历史记录，跳转到显示饼状图的界面
  void navigateToPieChartScreen(Map<String, dynamic> emotionData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PieChartScreen(emotionData: emotionData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史情感数据'),
        leading: Container(), // 去掉左上角的默认返回按钮
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: emotionHistory.length,
              itemBuilder: (context, index) {
                var data = emotionHistory[index];
                var date = DateTime.parse(data['analysis_timestamp']);
                var formattedDate = DateFormat('yyyy-MM-dd').format(date);

                return GestureDetector(
                  onTap: () {
                    // 点击后，跳转到饼状图界面
                    navigateToPieChartScreen(data['emotion_data']);
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   '分析ID: ${data['analysis_id']}',
                          //   style: const TextStyle(fontWeight: FontWeight.bold),
                          // ),
                          Text('分析时间: $formattedDate'),
                          const SizedBox(height: 10),
                          Text('分析时长: ${data['analysis_duration']} 秒'),
                          const SizedBox(height: 10),
                          const Text('点击查看详细情感数据的饼状图'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// PieChartScreen 显示饼状图的界面
class PieChartScreen extends StatelessWidget {
  final Map<String, dynamic> emotionData;

  const PieChartScreen({super.key, required this.emotionData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('情感分析饼状图'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PieChart(
                  PieChartData(
                    sections: showingSections(),
                    sectionsSpace: 2, // 设置扇区之间的间距
                    centerSpaceRadius: 40, // 中心空白部分的半径
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),
          // 图例
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(Colors.red, '愤怒'),
                _buildLegendItem(Colors.green, '厌恶'),
                _buildLegendItem(Colors.purple, '恐惧'),
                _buildLegendItem(Colors.yellow, '快乐'),
                _buildLegendItem(Colors.blue, '中性'),
                _buildLegendItem(Colors.orange, '悲伤'),
                _buildLegendItem(Colors.pink, '惊讶'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建图例项
  Widget _buildLegendItem(Color color, String emotion) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(emotion),
      ],
    );
  }

  // 构建饼状图的各个部分
  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: Colors.red,
        value: (emotionData['anger'] ?? 0) * 100, // 愤怒百分比
        radius: 50,
        title: '', // 移除标题
      ),
      PieChartSectionData(
        color: Colors.green,
        value: (emotionData['disgust'] ?? 0) * 100, // 厌恶百分比
        radius: 50,
        title: '', // 移除标题
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: (emotionData['fear'] ?? 0) * 100, // 恐惧百分比
        radius: 50,
        title: '', // 移除标题
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: (emotionData['happiness'] ?? 0) * 100, // 快乐百分比
        radius: 50,
        title: '', // 移除标题
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: (emotionData['neutral'] ?? 0) * 100, // 中性百分比
        radius: 50,
        title: '', // 移除标题
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: (emotionData['sadness'] ?? 0) * 100, // 悲伤百分比
        radius: 50,
        title: '', // 移除标题
      ),
      PieChartSectionData(
        color: Colors.pink,
        value: (emotionData['surprise'] ?? 0) * 100, // 惊讶百分比
        radius: 50,
        title: '', // 移除标题
      ),
    ];
  }
}
