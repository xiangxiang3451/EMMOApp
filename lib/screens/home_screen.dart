// lib/screens/home_screen.dart

import 'package:emotion_recognition/l10n/gen/app_localizations.dart';
import 'package:emotion_recognition/screens/calendar_screen.dart';
import 'package:emotion_recognition/screens/recordEmo_screen';
import 'package:flutter/material.dart';
import 'report_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 页面选项列表
  static final List<Widget> _widgetOptions = <Widget>[
    const CalendarScreen(),
    const ReportScreen(), // 报告页面
    const HistoryScreen(), // 历史数据页面
     MoodScreen(), // 设置页面
  ];

  // 页面切换方法
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 禁用默认的返回按钮
        centerTitle: true,
        backgroundColor: const Color(0xFF40514E), // 设置背景色
        elevation: 0, // 去掉阴影
        titleTextStyle: const TextStyle(
          color: Colors.black, // 标题文字为黑色
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // 图标为白色
        ),
        title: const Text('EMMO'),
        leading: IconButton(
          icon: const Icon(Icons.insert_emoticon), // 使用情绪图标
          onPressed: () {},
        ),
      ),

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // 根据选中的索引显示相应页面
      ),
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: '情感分析',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: '报告',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '历史数据',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.languageSettings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent, // 选中的项目为蓝色
        unselectedItemColor: Colors.white, // 未选中的项目为深灰色
        backgroundColor: const Color(0xFF3E4149), // 底部导航栏背景色为白色
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // 固定模式，确保未选中的图标保持原样
      ),
    );
  }
}
