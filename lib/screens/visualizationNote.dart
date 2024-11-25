import 'dart:convert';
import 'package:emmo/authentication/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Visualizationnote extends StatefulWidget {
  const Visualizationnote({super.key});

  @override
  State<Visualizationnote> createState() => _VisualizationnoteState();
}

class _VisualizationnoteState extends State<Visualizationnote> {
  List<Map<String, dynamic>> records = [];

  // 获取当前用户的记录
  Future<void> _getRecords() async {
    String? userId = AuthenticationService.currentUserEmail;
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户未登录！')),
        );
      });
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // 获取当前用户的记录集合
      final snapshot = await firestore
          .collection('record') // 记录集合
          .where('userId', isEqualTo: userId) // 按用户ID查询
          .orderBy('time', descending: true) // 按时间倒序排序
          .get();

      setState(() {
        records = snapshot.docs.map((doc) {
          return {
            'expression': doc['expression'], // 表情
            'color': doc['color'], // 颜色
            'date': doc['date'], // 日期
            'address': doc['address'], // 地址
            'thoughts': doc['thoughts'], // 思想/备注
            'photo': doc['photo'], // 图片 base64
          };
        }).toList();
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching records: $e')),
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getRecords(); // 获取当前用户的记录
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: records.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final expression = record['expression'];
                final colorValue = record['color'];

                final color =
                    colorValue is int ? Color(colorValue) : Colors.transparent;
                final date = record['date'];
                final address = record['address'];
                final thoughts = record['thoughts'];
                final photoBase64 = record['photo'];

                return InkWell(
                  onTap: () {
                    _showRecordDetails(context, record);
                  },
                  child: Card(
                    color: color,
                    margin: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      height: 120, // 固定高度
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color,
                            radius: 30,
                            child: Text(
                              expression,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '地址: $address',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '备注: $thoughts',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  const Text('日期: '),
                  Text(
                    date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text('地址: '),
                  Expanded(child: Text(address)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text('备注: '),
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
