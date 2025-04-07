// features/calendar/models/mood_record_model.dart
import 'dart:ui';

class MoodRecordModel {
  final String id;
  final String expression;
  final Color color;
  final DateTime date;
  final String address;
  final String thoughts;
  final String? photoBase64;

  MoodRecordModel({
    required this.id,
    required this.expression,
    required this.color,
    required this.date,
    required this.address,
    required this.thoughts,
    this.photoBase64,
  });

  factory MoodRecordModel.fromMap(Map<String, dynamic> map) {
    return MoodRecordModel(
      id: map['id'] ?? '',
      expression: map['expression'] ?? '',
      color: Color(map['color'] as int),
      date: DateTime.parse(map['date']),
      address: map['address'] ?? '',
      thoughts: map['thoughts'] ?? '',
      photoBase64: map['photo'],
    );
  }
}