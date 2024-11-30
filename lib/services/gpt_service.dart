import 'dart:convert';
import 'package:emmo/utils/constants.dart';
import 'package:http/http.dart' as http;

class GPTService {
  //API Key
  final String _apiKey = '$gptKey';

  Future<String> getEmotionResponse(String userInput) async {
    const apiUrl = 'https://sg.uiuiapi.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8', // 指定 UTF-8 编码
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant specialized in managing emotions.'
          },
          {'role': 'user', 'content': userInput},
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes)); // 确保解码为 UTF-8
      return data['choices'][0]['message']['content'];
    } else {
            throw Exception('Failed to fetch response from GPT API: ${utf8.decode(response.bodyBytes)}');

    }
}}
