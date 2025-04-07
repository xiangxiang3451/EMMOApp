// features/calendar/view_models/calendar_view_model.dart
import 'package:emmo/services/firebase_service.dart';
import 'package:flutter/material.dart';

class CalendarViewModel with ChangeNotifier {
  final FirebaseService _firebaseService;

  CalendarViewModel(this._firebaseService);

  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;

  Set<DateTime> _recordedDates = {};
  Set<DateTime> get recordedDates => _recordedDates;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadRecordedDates() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dates = await _firebaseService.getRecordedDates();
      _recordedDates = dates.map((date) => DateTime(date.year, date.month, date.day)).toSet();
    } catch (e) {
      // 处理错误
      debugPrint('Error loading recorded dates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<DateTime> getDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    return List.generate(lastDay.day, (index) => firstDay.add(Duration(days: index)));
  }

  int getFirstWeekdayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}