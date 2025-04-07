// features/calendar/views/calendar_screen.dart
import 'package:emmo/features/calendar/view_models/day_details_view_model.dart';
import 'package:emmo/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emmo/features/calendar/view_models/calendar_view_model.dart';
import 'package:emmo/features/calendar/views/day_details_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalendarViewModel(
        Provider.of<FirebaseService>(context, listen: false),
      )..loadRecordedDates(),
      child: Scaffold(
        backgroundColor: const Color(0xFF40514E),
        body: Consumer<CalendarViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final monthDate = DateTime(
                        viewModel.currentDate.year, 
                        viewModel.currentDate.month - index
                      );
                      return _MonthCalendar(
                        year: monthDate.year,
                        month: monthDate.month,
                        recordedDates: viewModel.recordedDates,
                        onDayTap: (day) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (_) => DayDetailsViewModel(
                                  Provider.of<FirebaseService>(context, listen: false),
                                  day,
                                )..loadRecords(),
                                child: const DayDetailsScreen(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Set<DateTime> recordedDates;
  final Function(DateTime) onDayTap;

  const _MonthCalendar({
    required this.year,
    required this.month,
    required this.recordedDates,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalendarViewModel>(context, listen: false);
    final daysInMonth = viewModel.getDaysInMonth(year, month);
    final firstWeekday = viewModel.getFirstWeekdayOfMonth(year, month);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "$month.$year",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            height: 330,
            decoration: BoxDecoration(
              color: const Color(0xFF40514E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: 42,
              itemBuilder: (context, gridIndex) {
                final dayIndex = gridIndex - firstWeekday + 1;
                if (dayIndex <= 0 || dayIndex > daysInMonth.length) {
                  return const SizedBox.shrink();
                }

                final day = daysInMonth[dayIndex - 1];
                final hasRecord = recordedDates.contains(day);

                return GestureDetector(
                  onTap: () => onDayTap(day),
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: hasRecord ? Colors.orange : Colors.green,
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Center(
                      child: Text(
                        '$dayIndex',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}