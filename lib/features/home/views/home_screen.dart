// features/home/views/home_screen.dart
import 'package:emmo/services/authentication_service.dart';
import 'package:emmo/features/calendar/views/calendar_screen.dart';
import 'package:emmo/features/chat/views/chat_screen.dart';
import 'package:emmo/features/home/view_models/home_view_model.dart';
import 'package:emmo/screens/game_screen.dart';
import 'package:emmo/screens/shared_screen.dart';
import 'package:emmo/screens/sound_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取依赖服务
    final authService = Provider.of<AuthenticationService>(context, listen: false);
    
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(
        widgetOptions: _buildWidgetOptions(context),
      ),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            key: viewModel.scaffoldKey,
            appBar: _buildAppBar(context, viewModel, authService),
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
      SoundScreen(),
      const Visualizationnote(),
    ];
  }

  AppBar _buildAppBar(
    BuildContext context,
    HomeViewModel viewModel,
    AuthenticationService authService,
  ) {
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
      title: const Text('EMMO'),
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

  Widget _buildBottomNavigationBar(HomeViewModel viewModel, BuildContext context) {
    return BottomNavigationBar(
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
              title: const Text(
                '选项 1',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text(
                '选项 2',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              title: const Text(
                '设置',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyGame()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}