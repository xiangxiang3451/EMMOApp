// features/calendar/views/day_details_screen.dart
import 'dart:convert';
import 'package:emmo/features/calendar/views/mood_record_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emmo/features/calendar/models/mood_record_model.dart';
import 'package:emmo/features/calendar/view_models/day_details_view_model.dart';

class DayDetailsScreen extends StatelessWidget {
  const DayDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DayDetailsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("${viewModel.date.year}-${viewModel.date.month}-${viewModel.date.day}"),
      ),
      body: Consumer<DayDetailsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.records.isEmpty) {
            return const Center(child: Text('No records for this day'));
          }

          return ListView.builder(
            itemCount: viewModel.records.length,
            itemBuilder: (context, index) {
              return MoodRecordCard(
                record: viewModel.records[index],
                onTap: () => _showRecordDetails(context, viewModel.records[index]),
              );
            },
          );
        },
      ),
    );
  }

  void _showRecordDetails(BuildContext context, MoodRecordModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.expression),
        backgroundColor: record.color,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('date: '),
                Text(record.date.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                const Text('address: '),
                Expanded(child: Text(record.address)),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                const Text('notes: '),
                Expanded(child: Text(record.thoughts)),
              ]),
              if (record.photoBase64 != null && record.photoBase64!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Center(
                  child: Image.memory(
                    base64Decode(record.photoBase64!),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('close'),
          ),
        ],
      ),
    );
  }
}