import 'dart:convert';

import 'package:emmo/services/firebase_service.dart';
import 'package:flutter/material.dart';

// 扩展 DateTime 类，添加 isSameDay 方法
extension DateTimeComparison on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late DateTime _currentDate;
  final ScrollController _scrollController = ScrollController();
  late Future<Set<DateTime>> _recordedDates;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _recordedDates = _fetchRecordedDates();
  }

  Future<Set<DateTime>> _fetchRecordedDates() async {
    // 获取所有情绪记录的日期
    List<DateTime> recordedDates = await _firebaseService.getRecordedDates();
    // 返回仅包含年月日部分的日期集合
    return recordedDates.map((date) => DateTime(date.year, date.month, date.day)).toSet();
  }

  void _viewDayDetails(BuildContext context, DateTime date) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DayDetailsScreen(date: date),
    ));
  }

  List<DateTime> _getDaysInMonth(int year, int month) {
    DateTime firstDay = DateTime(year, month, 1);
    DateTime lastDay = DateTime(year, month + 1, 0);
    return List.generate(lastDay.day, (index) => firstDay.add(Duration(days: index)));
  }

  int _getFirstWeekdayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF40514E),
      body: FutureBuilder<Set<DateTime>>(
        future: _recordedDates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recordedDates = snapshot.data ?? {};

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    DateTime monthDate = DateTime(_currentDate.year, _currentDate.month - index);
                    List<DateTime> daysInMonth = _getDaysInMonth(monthDate.year, monthDate.month);
                    int firstWeekday = _getFirstWeekdayOfMonth(monthDate.year, monthDate.month);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              "${monthDate.month}.${monthDate.year}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 330,
                            decoration: BoxDecoration(
                              color: const Color(0xFF40514E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: 42,
                              itemBuilder: (context, gridIndex) {
                                int dayIndex = gridIndex - firstWeekday + 1;
                                if (dayIndex <= 0 || dayIndex > daysInMonth.length) {
                                  return const SizedBox.shrink();
                                }

                                DateTime day = daysInMonth[dayIndex - 1];
                                bool hasRecord = recordedDates.contains(day);

                                return GestureDetector(
                                  onTap: () {
                                    _viewDayDetails(context, day);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: hasRecord ? Colors.orange : Colors.green,
                                      border: Border.all(color: Colors.transparent),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$dayIndex',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                  childCount: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class DayDetailsScreen extends StatelessWidget {
  final DateTime date;

  const DayDetailsScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text("${date.year}-${date.month}-${date.day}"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: firebaseService.getRecordsForDate(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(child: Text('当天没有记录'));
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final expression = record['expression'];
              final colorValue = record['color'];
              final color = colorValue is int ? Color(colorValue) : Colors.transparent;
              final address = record['address'];
              final thoughts = record['thoughts'];

              return Card(
                color: color,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: Text(expression, style: const TextStyle(fontSize: 24)),
                  ),
                  title: Text(address),
                  subtitle: Text(thoughts),
                  onTap: () => _showRecordDetails(context, record), // 添加点击事件
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRecordDetails(BuildContext context, Map<String, dynamic> record) {
    final expression = record['expression'];
    final colorValue = record['color'];
    final color = colorValue is int ? Color(colorValue) : Colors.transparent;
    final date = record['date'];
    final address = record['address'];
    final thoughts = record['thoughts'];
    final photoBase64 = record['photo'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$expression'),
        backgroundColor: color,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('date: '),
                  Text(
                    date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text('address: '),
                  Expanded(child: Text(address)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text('notes: '),
                  Expanded(child: Text(thoughts)),
                ],
              ),
              if (photoBase64 != null && photoBase64.isNotEmpty) ...[
                const SizedBox(height: 16),
                Center(
                  child: Image.memory(
                    base64Decode(photoBase64),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('close'),
          ),
        ],
      ),
    );
  }
}