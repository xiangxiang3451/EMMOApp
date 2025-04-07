// features/calendar/views/widgets/mood_record_card.dart
import 'package:flutter/material.dart';
import 'package:emmo/features/calendar/models/mood_record_model.dart';

class MoodRecordCard extends StatelessWidget {
  final MoodRecordModel record;
  final VoidCallback onTap;

  const MoodRecordCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: record.color,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.color,
          child: Text(record.expression, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(record.address),
        subtitle: Text(record.thoughts),
        onTap: onTap,
      ),
    );
  }
}