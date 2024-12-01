import 'package:emmo/services/gpt_service.dart';
import 'package:flutter/material.dart';

class EmotionChatPage extends StatefulWidget {
  @override
  _EmotionChatPageState createState() => _EmotionChatPageState();
}

class _EmotionChatPageState extends State<EmotionChatPage> {
  final GPTService _gptService = GPTService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 初始化聊天记录，包含初始问题
  final List<Map<String, String>> _chatHistory = [
    {
      'role': 'system',
      'content': 'You are a helpful assistant specialized in managing emotions.'
    },
    {
      'role': 'assistant',
      'content': 'Hello! How are you feeling now?',
    },
  ];

  // 控制输入框和按钮的显示状态
  bool _isInputVisible = true;
  bool _isSummaryShown = false;

  void _sendMessage() async {
    final userInput = _controller.text;
    if (userInput.isEmpty) return;

    // 添加用户输入到聊天历史
    setState(() {
      _chatHistory.add({'role': 'user', 'content': userInput});
      _controller.clear(); // 清空输入框内容
      _isInputVisible = false; // 隐藏输入框
    });

    // 滚动到底部以查看最新消息
    _scrollToBottom();

    try {
      final reply = await _gptService.getEmotionResponse(_chatHistory);

      setState(() {
        _chatHistory
            .add({'role': 'assistant', 'content': reply}); // 添加 GPT 回复到聊天历史
      });

      // 滚动到底部
      _scrollToBottom();
    } catch (error) {
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': 'Error: $error',
        });
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _continueConversation() {
    setState(() {
      _isInputVisible = true; // 显示输入框
    });
  }

  void _endAndSummarizeConversation() async {
    try {
      // 请求 GPT 总结聊天内容
      final summary = await _gptService.summarizeChat(_chatHistory);

      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': '$summary',
        });
        _isSummaryShown = true; // 显示总结状态
        _isInputVisible = false; // 隐藏输入框
      });

      // 滚动到底部以查看总结
      _scrollToBottom();
    } catch (error) {
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': 'Error summarizing conversation: $error',
        });
      });
    }
  }

  void _restartConversation() {
    setState(() {
      _chatHistory.clear();
      _chatHistory.addAll([
        {
          'role': 'system',
          'content': 'You are a helpful assistant specialized in managing emotions.'
        },
        {
          'role': 'assistant',
          'content': 'Hello! How are you feeling now?',
        },
      ]);
      _isInputVisible = true; // 显示输入框
      _isSummaryShown = false; // 重置总结状态
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final message = _chatHistory[index];
                  if (message['role'] == 'system') {
                    return const SizedBox.shrink(); // 不渲染 system 消息
                  }
                  final isUser = message['role'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['content']!,
                        style: TextStyle(
                            color: isUser ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            if (_isSummaryShown)
              Center(
                child: ElevatedButton(
                  onPressed: _restartConversation,
                  child: const Text('Restart Conversation'),
                ),
              )
            else if (_isInputVisible)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Enter your feelings',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Text('Send'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _continueConversation,
                    child: const Text('Continue'),
                  ),
                  ElevatedButton(
                    onPressed: _endAndSummarizeConversation,
                    child: const Text('End & Summarize'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
