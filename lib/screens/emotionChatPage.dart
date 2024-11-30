import 'package:emmo/services/gpt_service.dart';
import 'package:flutter/material.dart';

class EmotionChatPage extends StatefulWidget {
  @override
  _EmotionChatPageState createState() => _EmotionChatPageState();
}

class _EmotionChatPageState extends State<EmotionChatPage> {
  final GPTService _gptService = GPTService();
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  void _sendMessage() async {
    final userInput = _controller.text;
    if (userInput.isEmpty) return;

    setState(() {
      _response = 'Loading...';
    });

    try {
      final reply = await _gptService.getEmotionResponse(userInput);
      setState(() {
        _response = reply;
      });
    } catch (error) {
      setState(() {
        _response = 'Error: $error';
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter your feelings',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send'),
            ),
            const SizedBox(height: 20),
            Text(
              _response,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
