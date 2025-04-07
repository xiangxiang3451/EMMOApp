import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emmo/utils/constants.dart';

class GPTService {
  final String _apiKey = gptKey;

  Future<String> getEmotionResponse(List<Map<String, String>> chatHistory) async {
    const apiUrl = 'https://sg.uiuiapi.com/v1/chat/completions';
    
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: _buildHeaders(),
      body: jsonEncode(_buildRequestBody(chatHistory, 500)),
    );

    return _handleResponse(response);
  }

  Future<String> summarizeChat(List<Map<String, String>> chatHistory) async {
    const apiUrl = 'https://sg.uiuiapi.com/v1/chat/completions';
    
    final modifiedHistory = List<Map<String, String>>.from(chatHistory)
      ..add({
        'role': 'system',
        'content': 'Please summarize the following conversation in the language it was written in and use you to call the user'
      });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: _buildHeaders(),
      body: jsonEncode(_buildRequestBody(modifiedHistory, 500)),
    );

    return _handleResponse(response);
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_apiKey',
    };
  }

  Map<String, dynamic> _buildRequestBody(List<Map<String, String>> messages, int maxTokens) {
    return {
      'model': 'gpt-4',
      'messages': _truncateChatHistory(messages),
      'max_tokens': maxTokens,
      'temperature': 0.7,
    };
  }

  List<Map<String, String>> _truncateChatHistory(List<Map<String, String>> history) {
    const maxTokens = 3000;
    int currentTokens = 0;
    List<Map<String, String>> truncatedHistory = [];
    
    for (var message in history.reversed) {
      final tokenCount = _estimateTokenCount(message['content']!);
      if (currentTokens + tokenCount > maxTokens) break;
      truncatedHistory.insert(0, message);
      currentTokens += tokenCount;
    }

    return truncatedHistory;
  }

  int _estimateTokenCount(String content) {
    return content.split(' ').length;
  }

  String _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('API request failed: ${utf8.decode(response.bodyBytes)}');
    }
  }
}