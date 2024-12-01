import 'package:emmo/authentication/authentication_service.dart';
import 'package:emmo/services/gpt_service.dart';
import 'package:emmo/services/firebase_service.dart';
import 'package:flutter/material.dart';

class EmotionChatPage extends StatefulWidget {
  @override
  _EmotionChatPageState createState() => _EmotionChatPageState();
}

class _EmotionChatPageState extends State<EmotionChatPage> {
  final GPTService _gptService = GPTService();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? currentUserEmail = AuthenticationService.currentUserEmail;

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

  bool _isInputVisible = true;
  bool _isSummaryShown = false;
  String? _chatSummary;

  void _sendMessage() async {
    final userInput = _controller.text;
    if (userInput.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'content': userInput});
      _controller.clear();
      _isInputVisible = false;
    });

    _scrollToBottom();

    try {
      final reply = await _gptService.getEmotionResponse(_chatHistory);

      setState(() {
        _chatHistory.add({'role': 'assistant', 'content': reply});
      });

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
      _isInputVisible = true;
    });
  }

  void _endAndSummarizeConversation() async {
    try {
      final summary = await _gptService.summarizeChat(_chatHistory);

      setState(() {
        _chatSummary = summary;
        _chatHistory.add({'role': 'assistant', 'content': summary});
        _isSummaryShown = true;
        _isInputVisible = false;
      });

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

  void _restartConversation() async {
    if (_chatSummary != null) {
      try {
        // 使用全局变量的用户邮箱
        await _firebaseService.saveChatSummary(
            currentUserEmail!, _chatSummary!);
      } catch (error) {
        setState(() {
          _chatHistory.add({
            'role': 'assistant',
            'content': 'Error saving summary: $error',
          });
        });
        return;
      }
    }

    setState(() {
      _chatHistory.clear();
      _chatHistory.addAll([
        {
          'role': 'system',
          'content':
              'You are a helpful assistant specialized in managing emotions.'
        },
        {
          'role': 'assistant',
          'content': 'Hello! How are you feeling now?',
        },
      ]);
      _isInputVisible = true;
      _isSummaryShown = false;
      _chatSummary = null;
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
                    return const SizedBox.shrink();
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
