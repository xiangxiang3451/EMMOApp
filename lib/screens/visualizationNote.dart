import 'dart:convert';

import 'package:emmo/authentication/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      // 如果用户未登录，使用 SchedulerBinding 延迟调用显示 SnackBar
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
      // 错误处理
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
          ? const Center(child: CircularProgressIndicator()) // 显示加载状态
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final expression = record['expression'];
                final colorValue = record['color']; // 获取 color 值（整数）

                // 确保 colorValue 是整数类型，然后传递给 Color 构造函数
                final color =
                    colorValue is int ? Color(colorValue) : Colors.transparent;
                final date = record['date'];
                final address = record['address'];
                final thoughts = record['thoughts'];
                final photoBase64 = record['photo'];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text(
                        expression,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    title: Text(date),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('地址: $address'),
                        const SizedBox(height: 4),
                        Text('备注: $thoughts'),
                        if (photoBase64 != null && photoBase64.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          // 显示图片（如果有）
                          Image.memory(
                            base64Decode(photoBase64),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
