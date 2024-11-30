import 'package:emmo/screens/calendar_screen.dart';
import 'package:emmo/screens/emotionChatPage.dart';
import 'package:emmo/screens/mood_screen.dart';
import 'package:emmo/screens/setting_screen.dart';
import 'package:emmo/screens/statistics_screen.dart';
import 'package:emmo/screens/visualizationNote.dart';
import 'package:flutter/material.dart';

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
    EmotionChatPage(), 
    const Visualizationnote(), 
    const StatisticsScreen(), 
    const SettingScreen()
  ];

  // 页面切换方法
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // // 判断点击的是否是 "语言设置" 项，如果是，显示 MoodScreen
    // if (index == 3) {
    //   _openMoodScreen();
    // }
  }

  // 打开MoodScreen页面的方法
  void _openMoodScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoodScreen()), // 跳转到MoodScreen
    );
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
          icon: const Icon(Icons.mode), // 使用铅笔
          onPressed: _openMoodScreen, // 用户点击时打开 MoodScreen 页面
        ),
      ),

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // 根据选中的索引显示相应页面
      ),
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Talk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.museum),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent, // 选中的项目为蓝色
        unselectedItemColor: Colors.white, // 未选中的项目为深灰色
        backgroundColor: const Color(0xFF3E4149), // 底部导航栏背景色为白色
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // 固定模式，确保未选中的图标保持原样
        iconSize: 20,
      ),
    );
  }
}
