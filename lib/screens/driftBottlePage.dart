import 'package:flutter/material.dart';
import 'package:emmo/services/firebase_service.dart';

class DriftBottlePage extends StatefulWidget {
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
  bool _isLoadingPick = false; // 拾取漂流瓶的加载状态

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
      _isLoadingPick = true;
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
        _isLoadingPick = false;
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
      await _firebaseService.respondToBottle(_currentBottle!["id"], responseContent);
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

  /// 显示扔漂流瓶窗口
  void _showThrowBottleDialog() {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: _bottleController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "写下你的感受...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoadingThrow ? null : _submitBottle,
                  child: _isLoadingThrow
                      ? const CircularProgressIndicator()
                      : const Text("扔漂流瓶"),
                ),
              ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentBottle == null)
                const Text(
                  "正在寻找漂流瓶...",
                  style: TextStyle(fontSize: 16),
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
                      width: double.infinity,  // 使其宽度与输入框一致
                      child: Text(
                        "${_currentBottle!['content']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                      width: double.infinity,  // 保证宽度一致
                      child: TextField(
                        controller: _responseController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "写下你的鼓励话语...",
                          border: InputBorder.none,  // 移除内部边框
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoadingResponse ? null : _respondToBottle,
                      child: _isLoadingResponse
                          ? const CircularProgressIndicator()
                          : const Text("发送回应"),
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
                  image: AssetImage('assets/images/bottle.jpg'), // 图片路径
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 按钮层，悬浮在图片上
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Colors.blue.withOpacity(0.7), // 半透明背景
                    ),
                    child: const Text("扔漂流瓶",style: TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _showPickBottleDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Colors.blue.withOpacity(0.7), // 半透明背景
                    ),
                    child: const Text("拾取漂流瓶",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
