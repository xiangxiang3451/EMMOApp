// lib/features/home/views/home_screen.dart
import 'package:emmo/features/authentication/login_screen.dart';
import 'package:emmo/features/calendar/views/calendar_screen.dart';
import 'package:emmo/features/chat/views/chat_screen.dart';
import 'package:emmo/features/home/view_models/home_view_model.dart';
import 'package:emmo/screens/game_screen.dart';
import 'package:emmo/screens/shared_screen.dart';
import 'package:emmo/screens/sound_Screen.dart';
import 'package:emmo/services/export_pdf.dart';
import 'package:emmo/services/language.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(
        widgetOptions: _buildWidgetOptions(context),
      ),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            key: viewModel.scaffoldKey,
            appBar: _buildAppBar(context, viewModel),
            body: viewModel.currentPage,
            bottomNavigationBar: _buildBottomNavigationBar(viewModel, context),
            drawer: _buildDrawer(context),
          );
        },
      ),
    );
  }

  List<Widget> _buildWidgetOptions(BuildContext context) {
    return <Widget>[
      const CalendarScreen(),
      const ChatScreen(),
      const MyGame(),
      const SoundScreen(),
      const Visualizationnote(),
    ];
  }

  AppBar _buildAppBar(BuildContext context, HomeViewModel viewModel) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: const Color(0xFF40514E),
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text('EMMO'), // 使用 I18N 获取当前语言的文本
      leading: IconButton(
        icon: const Icon(Icons.mode),
        onPressed: () => viewModel.openMoodScreen(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.table_rows),
          onPressed: viewModel.openDrawer,
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(
      HomeViewModel viewModel, BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.museum),
          label: I18N.translate('home'), // 动态翻译
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.psychology),
          label: I18N.translate('talk'), // 动态翻译
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.games),
          label: I18N.translate('games'), // 动态翻译
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.access_time),
          label: I18N.translate('relax'), // 动态翻译
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: I18N.translate('settings'), // 动态翻译
        ),
      ],
      currentIndex: viewModel.selectedIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white,
      backgroundColor: const Color(0xFF3E4149),
      onTap: (index) => viewModel.onItemTapped(index, context),
      type: BottomNavigationBarType.fixed,
      iconSize: 20,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Drawer(
        backgroundColor: const Color(0xFF62D2A2),
        child: ListView(
          padding: const EdgeInsets.all(22.0),
          children: [
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf, // PDF 图标
                color: Colors.white,
              ),
              title: Text(
                I18N.translate('export_pdf'), // 使用 I18N 获取当前语言的文本
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                // 导出 PDF
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExportPdfScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.language, // 语言图标
                color: Colors.white,
              ),
              title: Text(
                I18N.translate('language'), // 使用 I18N 获取当前语言的文本
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              onTap: () {
                // 切换语言
                String newLang = I18N.currentLanguage == 'en' ? 'zh' : 'en';
                I18N.setLanguage(newLang); // 设置新的语言
                setState(() {}); // 通过 setState 刷新 UI
                Navigator.pop(context); // 关闭抽屉
              },
            ),
            const Divider(
              color: Colors.white70,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.exit_to_app, // 退出图标
                color: Colors.white,
              ),
              title: Text(
                I18N.translate('exit'), // 使用 I18N 获取当前语言的文本
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false, // 这个条件会移除掉所有的路由
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
