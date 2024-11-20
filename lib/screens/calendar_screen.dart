import 'package:flutter/material.dart';
// import 'dart:convert';

// 扩展 DateTime 类，添加 isSameDay 方法
extension DateTimeComparison on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final Map<DateTime, String> _selectedEmotions = {}; // 存储每个日期的情绪
  late DateTime _selectedDate; // 当前选中的日期
  late DateTime _currentDate; // 当前日期
  final ScrollController _scrollController = ScrollController(); // 滚动控制器

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentDate = DateTime.now(); // 获取当前日期
    // _loadEmotions(); // 加载情绪数据
  }

  // // 从 Flask API 加载情绪数据
  // Future<void> _loadEmotions() async {
  //   final userId = User().userId; // 获取用户ID
  //   final response = await http.get(
  //     Uri.parse('$BackEndUrl/emotions/$userId'), // 使用正确的 URL
  //   );

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body); // 解析数据
  //     setState(() {
  //       _selectedEmotions.clear(); // 清空之前的数据
  //       data.forEach((dateStr, emotion) {
  //         DateTime date = DateTime.parse(dateStr); // 解析日期
  //         _selectedEmotions[date] = emotion; // 存储情绪数据
  //       });
  //     });
  //   } else {
  //     print('Failed to load emotions: ${response.body}');
  //   }
  // }

  // // 保存情绪数据到 Flask API
  // Future<void> _saveEmotion(DateTime date, String emotion) async {
  //   final userId = User().userId; // 获取用户ID
  //   final response = await http.post(
  //     Uri.parse('$BackEndUrl/emotion/emotions'), // 使用 POST 请求保存情绪
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'userId': userId,
  //       'date': date.toIso8601String(),
  //       'emotion': emotion,
  //     }),
  //   );

  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     setState(() {
  //       _selectedEmotions[date] = emotion; // 更新情绪
  //     });
  //   } else {
  //     print('Failed to save emotion: ${response.body}');
  //   }
  // }

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

  // 单个情绪按钮
  Widget _emotionButton(String emoji, DateTime date) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        // _saveEmotion(date, emoji); // 保存选择的情绪
      },
      child: Text(emoji, style: const TextStyle(fontSize: 30)),
    );
  }

  // 获取指定月份的天数
  List<DateTime> _getDaysInMonth(int year, int month) {
    DateTime firstDay = DateTime(year, month, 1); // 获取该月的第一天
    DateTime lastDay = DateTime(year, month + 1, 0); // 获取该月的最后一天

    List<DateTime> days = [];
    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i))); // 生成该月的所有日期
    }
    return days;
  }

  // 获取指定月份的第一天星期几
  int _getFirstWeekdayOfMonth(int year, int month) {
    DateTime firstDay = DateTime(year, month, 1); // 获取该月的第一天
    return firstDay.weekday; // 获取该天是星期几
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF40514E), 
      body: CustomScrollView(
        controller: _scrollController, // 使用控制器
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // 通过当前日期倒推，显示当前月份及之前的月份
                DateTime monthDate =
                    DateTime(_currentDate.year, _currentDate.month - index);
                List<DateTime> daysInMonth = _getDaysInMonth(
                    monthDate.year, monthDate.month); // 获取该月的所有日期
                int firstWeekday = _getFirstWeekdayOfMonth(
                    monthDate.year, monthDate.month); // 获取该月第一天是星期几

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          color: const Color(0xFF40514E),  // 设置背景色为 #40514E
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "${monthDate.month}.${monthDate.year} ",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // 设置字体颜色为白色
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 330, // 每个月日历的高度
                        decoration: BoxDecoration(
                          color: const Color(0xFF40514E), // 设置背景色为 #40514e
                          borderRadius: BorderRadius.circular(10), // 设置边框圆角
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2), // 位置偏移
                            ),
                          ],
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7, // 一周7天
                            childAspectRatio: 1.0, // 每个格子的宽高比
                          ),
                          itemCount: 42, // 每个月的最大格子数（6行 * 7列）
                          itemBuilder: (context, gridIndex) {
                            int dayIndex = gridIndex - firstWeekday + 1;

                            if (dayIndex <= 0 ||
                                dayIndex > daysInMonth.length) {
                              return const SizedBox.shrink(); // 空格子
                            }

                            DateTime day = daysInMonth[dayIndex - 1]; // 当前日期
                            String emotion =
                                _selectedEmotions[day] ?? ''; // 获取该日期的情绪

                            // 确保当前日期在屏幕上
                            if (day.isSameDay(_currentDate)) {
                              // 滚动到当前日期
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollController.jumpTo(200.0); // 定位到当前日期
                              });
                            }

                            return GestureDetector(
                              onTap: () {
                                _selectEmotion(day); // 选择情绪
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: emotion.isNotEmpty
                                      ? Colors.green
                                      : null, // 有情绪时背景色
                                  border: Border.all(color: Colors.transparent), // 去掉边框
                                ),
                                child: Center(
                                  child: Text(
                                    '$dayIndex',
                                    style: const TextStyle(
                                      fontSize: 18,  // 加大字体
                                      fontWeight: FontWeight.bold,  // 加粗字体
                                      color: Colors.white, // 设置字体颜色为白色
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: 12, // 一年12个月
            ),
          ),
        ],
      ),
    );
  }
}
