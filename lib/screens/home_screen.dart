import 'package:emmo/screens/soundScreen.dart';
import 'package:emmo/screens/visualizationNote.dart';
import 'package:flutter/material.dart';
import 'package:emmo/screens/calendar_screen.dart';
import 'package:emmo/screens/emotionChatPage.dart';
import 'package:emmo/screens/mood_screen.dart';
import 'package:emmo/screens/myGame_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 创建一个 GlobalKey，用来控制 Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 页面选项列表
  static final List<Widget> _widgetOptions = <Widget>[
    const CalendarScreen(),
    const EmotionChatPage(),
    MyGame(),
    SoundScreen(),
    const Visualizationnote(),
  ];

  // 页面切换方法
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 打开MoodScreen页面的方法
  void _openMoodScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const MoodScreen()), // 跳转到MoodScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 给 Scaffold 设置 GlobalKey
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
          icon: const Icon(Icons.mode), // 使用铅笔图标
          onPressed: _openMoodScreen, // 用户点击时打开 MoodScreen 页面
        ),
        actions: [
          // 添加设置按钮到右侧
          IconButton(
            icon: const Icon(Icons.table_rows), // 设置按钮的图标
            onPressed: () {
              // 使用 _scaffoldKey 打开侧边栏
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // 根据选中的索引显示相应页面
      ),
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.museum),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Talk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Relax",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Games",
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
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        child: Drawer(
          backgroundColor: const Color(0xFF62D2A2),
          child: ListView(
            padding: const EdgeInsets.all(22.0),
            children: [
              ListTile(
                title: const Text('选项 1',style: TextStyle(color: Colors.white),),
                onTap: () {
                  Navigator.pop(context); // 关闭 Drawer
                },
              ),
              ListTile(
                title: const Text('选项 2',style: TextStyle(color: Colors.white),),
                onTap: () {
                  Navigator.pop(context); // 关闭 Drawer
                },
              ),
              const Divider(), // 分割线
              // 设置项
              ListTile(
                title: const Text('设置',style: TextStyle(color: Colors.white),),
                onTap: () {
                  Navigator.pop(context); // 关闭 Drawer
                  // 展示设置内容，跳转到设置页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyGame()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
