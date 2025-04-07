// features/chat/models/message_model.dart
class MessageModel {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime? timestamp;

  MessageModel({
    required this.role,
    required this.content,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      role: map['role'],
      content: map['content'],
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : null,
    );
  }
}