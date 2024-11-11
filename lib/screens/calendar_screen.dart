import 'package:emotion_recognition/models/constants.dart';
import 'package:emotion_recognition/services/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final Map<DateTime, String> _selectedEmotions = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadEmotions();  // 加载情绪数据
  }

  // 从 Flask API 加载情绪数据
  Future<void> _loadEmotions() async {
    final userId = User().userId;  // 获取用户ID
    final response = await http.get(
      Uri.parse('$BackEndUrl/emotions/${userId}'), // 使用正确的 URL
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body); // 解析为 Map 类型
      setState(() {
        _selectedEmotions.clear(); // 清空之前的数据
        data.forEach((dateStr, emotion) {
          DateTime date = DateTime.parse(dateStr); // 解析日期字符串
          _selectedEmotions[date] = emotion; // 将情绪存储在 Map 中
        });
      });
    } else {
      print('Failed to load emotions: ${response.body}');
    }
  }

  // 保存情绪数据到 Flask API
  Future<void> _saveEmotion(DateTime date, String emotion) async {
    final userId = User().userId;  // 获取用户ID
    final response = await http.post(
      Uri.parse('$BackEndUrl/emotion/emotions'), // 使用 POST 请求保存情绪
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'date': date.toIso8601String(),
        'emotion': emotion,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      setState(() {
        _selectedEmotions[date] = emotion; // 保存或更新情绪
      });
    } else {
      print('Failed to save emotion: ${response.body}');
    }
  }

  // 显示情绪选择对话框
  void _selectEmotion(DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("选择你的情绪"),
          content: Wrap(
            spacing: 10.0,
            children: [
              _emotionButton("😊", date),
              _emotionButton("😔", date),
              _emotionButton("😡", date),
              _emotionButton("😱", date),
              _emotionButton("😴", date),
            ],
          ),
        );
      },
    );
  }

  Widget _emotionButton(String emoji, DateTime date) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        _saveEmotion(date, emoji); // 保存选择的情绪
      },
      child: Text(emoji, style: const TextStyle(fontSize: 30)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 显示年份和月份
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${_focusedDay.year}年 ${_focusedDay.month}月",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // 使用 SingleChildScrollView 来支持上下滚动
          Expanded(
            child: SingleChildScrollView(
              child: TableCalendar(
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.now(), // 只允许选择到今天
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _selectEmotion(selectedDay);  // 点击日期选择情绪
                },
                calendarBuilders: CalendarBuilders(
                  // 自定义日历单元格显示
                  defaultBuilder: (context, day, focusedDay) {
                    final emotion = _selectedEmotions[day];
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey, width: 1), // 右边框
                          bottom: BorderSide(color: Colors.grey, width: 1), // 下边框
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emotion ?? day.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: emotion == null ? Colors.black : Colors.blue,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
