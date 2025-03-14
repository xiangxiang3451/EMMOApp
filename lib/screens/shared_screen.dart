import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:emmo/authentication/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Visualizationnote extends StatefulWidget {
  const Visualizationnote({super.key});

  @override
  State<Visualizationnote> createState() => _VisualizationnoteState();
}

class _VisualizationnoteState extends State<Visualizationnote> {
  List<Map<String, dynamic>> records = [];
  String? pairedUserEmail;

  @override
  void initState() {
    super.initState();
    _getPairedUser(); // 获取配对用户
    _getRecords(); // 获取当前用户的记录
  }

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

  // 获取配对用户
  Future<void> _getPairedUser() async {
    final email = await AuthenticationService.getPairedUserEmail();
    setState(() {
      pairedUserEmail = email;
    });
  }

  // 获取对方用户的心情记录
  Stream<List<Map<String, dynamic>>> _getPairedUserMoods() {
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('record')
        .where('userId', isEqualTo: pairedUserEmail)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'expression': doc['expression'],
          'color': doc['color'],
          'date': doc['date'],
          'address': doc['address'],
          'thoughts': doc['thoughts'],
          'photo': doc['photo'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('心情记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getRecords(); // 刷新当前用户记录
              _getPairedUser(); // 刷新配对用户
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // 跳转到配对界面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PairingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_remove),
            onPressed: () async {
              await AuthenticationService.unpairUsers();
              setState(() {
                pairedUserEmail = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已解除配对')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white.withOpacity(0.8),
        child: pairedUserEmail == null
            ? const Center(child: Text('未配对用户'))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getPairedUserMoods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('对方暂无心情记录'));
                  }

                  final pairedRecords = snapshot.data!;

                  return ListView.builder(
                    itemCount: pairedRecords.length,
                    itemBuilder: (context, index) {
                      final record = pairedRecords[index];
                      final expression = record['expression'];
                      final colorValue = record['color'];
                      final color = colorValue is int
                          ? Color(colorValue)
                          : Colors.transparent;
                      final date = record['date'];
                      final address = record['address'];
                      final thoughts = record['thoughts'];
                      final photoBase64 = record['photo'];

                      return InkWell(
                        onTap: () {
                          _showRecordDetails(context, record);
                        },
                        child: Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          color: color,
                          margin: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            height: 110,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        'address: $address',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'note: $thoughts',
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
                  );
                },
              ),
      ),
    );
  }

  // 显示心情记录详情
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
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _pairCodeController = TextEditingController();
  bool _isLoading = false;
  String? _currentPairCode;

  @override
  void initState() {
    super.initState();
    _loadPairCode(); // 加载当前用户的配对码
  }

  // 加载当前用户的配对码
  Future<void> _loadPairCode() async {
    final currentUserEmail = AuthenticationService.currentUserEmail;
    if (currentUserEmail == null) return;

    final firestore = FirebaseFirestore.instance;
    final userDoc =
        await firestore.collection('users').doc(currentUserEmail).get();

    if (userDoc.exists) {
      setState(() {
        _currentPairCode = userDoc['pairCode'];
      });
    }
  }

  // 处理配对逻辑
  Future<void> _pairUsers() async {
    final pairCode = _pairCodeController.text.trim();
    if (pairCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入配对码')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthenticationService.pairUsers(pairCode);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('配对成功！')),
        );
        Navigator.pop(context); // 返回上一页
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('配对失败，请检查配对码')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('配对失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户配对'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_currentPairCode != null) ...[
              Text(
                '您的配对码：$_currentPairCode',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _pairCodeController,
              decoration: const InputDecoration(
                labelText: '输入配对码',
                hintText: '请输入6位配对码',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _pairUsers,
                    child: const Text('配对'),
                  ),
          ],
        ),
      ),
    );
  }
}
