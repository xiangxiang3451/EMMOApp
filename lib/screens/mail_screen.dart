import 'package:flutter/material.dart';
import 'package:emmo/services/firebase_service.dart';

class DriftBottlePage extends StatefulWidget {
  const DriftBottlePage({super.key});

  @override
  _DriftBottlePageState createState() => _DriftBottlePageState();
}

class _DriftBottlePageState extends State<DriftBottlePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _bottleController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  Map<String, dynamic>? _currentBottle;

  bool _isLoadingThrow = false; // 扔漂流瓶的加载状态
  bool _isLoadingResponse = false; // 回复漂流瓶的加载状态
// 拾取漂流瓶的加载状态

  /// 扔漂流瓶
  void _submitBottle() async {
    final content = _bottleController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("感受内容不能为空！")),
      );
      return;
    }

    setState(() {
      _isLoadingThrow = true;
    });

    try {
      await _firebaseService.createBottle(content);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("漂流瓶已成功投出！")),
      );
      _bottleController.clear();
      Navigator.pop(context); // 关闭弹窗
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("投出漂流瓶失败：$e")),
      );
    } finally {
      setState(() {
        _isLoadingThrow = false;
      });
    }
  }

  /// 拾取漂流瓶
  void _pickBottle() async {
    setState(() {
    });

    try {
      final bottle = await _firebaseService.pickBottle();
      if (bottle != null) {
        setState(() {
          _currentBottle = bottle;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("没有更多漂流瓶可拾取！")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("拾取漂流瓶失败：$e")),
      );
    } finally {
      setState(() {
      });
    }
  }

  /// 回复漂流瓶
  void _respondToBottle() async {
    if (_currentBottle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请先拾取一个漂流瓶！")),
      );
      return;
    }

    final responseContent = _responseController.text.trim();
    if (responseContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("回复内容不能为空！")),
      );
      return;
    }

    setState(() {
      _isLoadingResponse = true; // 开始加载状态
    });

    try {
      await _firebaseService.respondToBottle(
          _currentBottle!["id"], responseContent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("回应已成功发送！")),
      );

      // 清空输入框并更新状态
      setState(() {
        _currentBottle = null;
        _responseController.clear();
      });

      Navigator.pop(context); // 关闭弹窗
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("发送回应失败，请稍后再试：$e")),
      );
    } finally {
      setState(() {
        _isLoadingResponse = false; // 完成后结束加载状态
      });
    }
  }

  /// 展示收到的回信内容
  void _showReceivedResponsesDialog() async {
    try {
      final receivedData = await _firebaseService.getReceivedResponses();

      if (receivedData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("你还没有收到任何回信！")),
        );
        return;
      }

      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            color: const Color.fromRGBO(238, 199, 140, 1),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: receivedData.length,
              itemBuilder: (context, index) {
                final bottle = receivedData[index];
                final responses = bottle['responses'] as List<dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 显示用户的信内容
                        Text(
                          "Your Letter: ${bottle['bottle_content']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 展示对应的所有回复
                        ...responses.map((response) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Reply: ${response['response_content']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Date: ${response['created_at']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("获取回信失败：$e")),
      );
    }
  }

  /// 显示扔漂流瓶窗口
  void _showThrowBottleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent, // 使背景透明，以便自定义颜色生效
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: FractionallySizedBox(
            heightFactor: 0.55, // 设置页面高度为屏幕的
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(238, 199, 140, 1), // 设置背景颜色为白色，可修改为任何颜色
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bottleController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Write your feelings...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // 按钮靠右对齐
                    children: [
                      ElevatedButton(
                        onPressed: _isLoadingThrow ? null : _submitBottle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // 设置按钮背景颜色
                          foregroundColor:
                              const Color.fromARGB(66, 32, 31, 31), // 设置按钮文本颜色
                          disabledBackgroundColor: Colors.grey, // 不可点击时的背景色
                          disabledForegroundColor: Colors.black45, // 不可点击时的文本颜色
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ), // 设置按钮内边距
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // 设置按钮圆角
                          ),
                        ),
                        child: _isLoadingThrow
                            ? const CircularProgressIndicator(
                                color: Colors.white, // 加载时进度条颜色
                              )
                            : const Text(
                                "Send",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16), // 添加按钮与屏幕右侧的间距
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 显示拾取漂流瓶窗口
  void _showPickBottleDialog() {
    _pickBottle();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: const Color.fromRGBO(238, 199, 140, 1), // 修改页面背景颜色
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentBottle == null)
                  const Text(
                    "正在寻找漂流瓶...",
                    style: TextStyle(
                        fontSize: 18, color: Colors.white), // 修改文本颜色和字体大小
                  )
                else
                  Column(
                    children: [
                      // 漂流瓶的内容显示在不可编辑的 Text 中，并添加边框
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity, // 使其宽度与输入框一致
                        child: Text(
                          "${_currentBottle!['content']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // 设置文本颜色
                          ),
                          textAlign: TextAlign.left, // 居中显示
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 回复的输入框，添加边框，并与漂流瓶内容框宽度一致
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity, // 保证宽度一致
                        child: TextField(
                          controller: _responseController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                "Write down your words of encouragement...",
                            border: InputBorder.none, // 移除内部边框
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 修改按钮的颜色和大小
                      ElevatedButton(
                        onPressed: _isLoadingResponse ? null : _respondToBottle,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange, // 设置按钮文本颜色
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 32,
                          ), // 设置按钮的内边距
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: _isLoadingResponse
                            ? const CircularProgressIndicator()
                            : const Text("Send"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            // 背景图片
            Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/mail.jpg'), // 图片路径
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 顶部按钮层，悬浮在图片上
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _showThrowBottleDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor:
                            Colors.orange.withOpacity(0.7), // 半透明背景
                      ),
                      child: const Text(
                        "Write Letter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _showPickBottleDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor:
                            Colors.orange.withOpacity(0.7), // 半透明背景
                      ),
                      child: const Text(
                        "Pick Letter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 查看回复按钮，放置在底部中间
            Positioned(
              bottom: 30, // 调整底部距离，保持美观
              right: 30, // 让按钮靠右对齐
              child: FloatingActionButton(
                onPressed: _showReceivedResponsesDialog,
                backgroundColor: Colors.orange.withOpacity(0.7), // 半透明背景
                tooltip: 'View Replies',
                child: const Icon(
                  Icons.mark_email_read, // 信封带勾的图标，表示查看回复
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
