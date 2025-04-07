// features/home/view_models/home_view_model.dart
import 'package:emmo/screens/mood_screen.dart';
import 'package:emmo/screens/shared_screen.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int get selectedIndex => _selectedIndex;
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  final List<Widget> _widgetOptions;

  HomeViewModel({required List<Widget> widgetOptions})
      : _widgetOptions = widgetOptions;

  Widget get currentPage => _widgetOptions.elementAt(_selectedIndex);

  void onItemTapped(int index, BuildContext context) {
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Visualizationnote()),
      );
    } else {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void openMoodScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoodScreen()),
    );
  }
}