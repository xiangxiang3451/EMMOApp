import 'package:flutter/material.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en', ''); // 默认语言为英语

  Locale get locale => _locale;

  void changeLanguage(Locale locale) {
    _locale = locale;
    notifyListeners(); // 通知所有监听者更新
  }
}
