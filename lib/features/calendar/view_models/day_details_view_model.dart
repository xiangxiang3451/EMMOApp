// features/calendar/view_models/day_details_view_model.dart
import 'package:emmo/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:emmo/features/calendar/models/mood_record_model.dart';

class DayDetailsViewModel with ChangeNotifier {
  final FirebaseService _firebaseService;
  final DateTime date;

  DayDetailsViewModel(this._firebaseService, this.date);

  List<MoodRecordModel> _records = [];
  List<MoodRecordModel> get records => _records;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      final records = await _firebaseService.getRecordsForDate(date);
      _records = records.map((r) => MoodRecordModel.fromMap(r)).toList();
    } catch (e) {
      debugPrint('Error loading records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}