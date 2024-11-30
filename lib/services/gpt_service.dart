import 'dart:convert';
import 'package:emmo/utils/constants.dart';
import 'package:http/http.dart' as http;

class GPTService {
  final String _apiKey = '$gptKey';

  Future<String> getEmotionResponse(List<Map<String, String>> chatHistory) async {
    const apiUrl = 'https://sg.uiuiapi.com/v1/chat/completions';

    // 截断聊天记录
    final truncatedHistory = _truncateChatHistory(chatHistory);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': truncatedHistory,
        'max_tokens': 500, // 提高最大 token 数
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to fetch response from GPT API: ${utf8.decode(response.bodyBytes)}');
    }
  }

  List<Map<String, String>> _truncateChatHistory(List<Map<String, String>> history) {
    const maxTokens = 3000; // 模型支持的最大 token，留出一定余量
    int currentTokens = 0;

    // 从最新消息向前累加，直到接近 maxTokens
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
    return content.split(' ').length; // 粗略将单词数量作为 token 数
  }
}
