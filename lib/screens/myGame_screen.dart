import 'package:emmo/screens/mailBox_Screen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final List<OverlayEntry> _overlayEntries = [];

class MyGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      home: GameHomePage(),
    );
  }
}

class GameHomePage extends StatefulWidget {
  @override
  _GameHomePageState createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  final List<Map<String, dynamic>> games = [
    {
      'name': 'Destress',
      'url':
          'https://www.hoodamath.com/mobile/games/destress-game/game.html?nocheckorient=1',
      'icon': Icons.videogame_asset,
    },
    {
      'name': 'Piano Tiles',
      'url':
          'https://www.hoodamath.com/mobile/games/piano-tiles/game.html?nocheckorient=1',
      'icon': Icons.videogame_asset,
    },
    {
      'name': 'Cubeform',
      'url':
          'https://www.hoodamath.com/mobile/games/cubeform/game.html?nocheckorient=1',
      'icon': Icons.videogame_asset,
    },
    {
      'name': 'tic-tac-toe',
      'url':
          'https://www.hoodamath.com/mobile/games/tic-tac-toe/game.html?nocheckorient=1',
      'icon': Icons.videogame_asset,
    },
  ];

  void _showGameFullScreen(String url) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => FullScreenGamePage(
        gameUrl: url,
        onClose: () {
          if (overlayEntry != null && _overlayEntries.contains(overlayEntry)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              overlayEntry?.remove();
              _overlayEntries.remove(overlayEntry);
            });
          }
        },
      ),
    );

    _overlayEntries.add(overlayEntry);
    Overlay.of(navigatorKey.currentContext!)?.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕的宽度和高度
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 游戏列表的响应式布局
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 响应式游戏列表
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: games.map((game) {
                          return GestureDetector(
                            onTap: () => _showGameFullScreen(game['url']),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              width: screenWidth * 0.25, // 使用屏幕宽度的百分比
                              child: Column(
                                children: [
                                  Icon(game['icon'],
                                      size: 50, color: Colors.blue),
                                  const SizedBox(height: 5),
                                  Text(
                                    game['name'],
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Divider(thickness: 1, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          // 改进后的响应式文本框
          Positioned(
            bottom: screenHeight * 0.2, // 根据屏幕高度调整文本框的垂直位置
            right: screenWidth * 0.1, // 根据屏幕宽度调整文本框的水平位置
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Here you can share\n your mood with others！',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 16,
            child: Tooltip(
              message: 'Click to view the letter you received',
              preferBelow: false,
              verticalOffset: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriftBottlePage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.email,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenGamePage extends StatelessWidget {
  final String gameUrl;
  final VoidCallback onClose;

  FullScreenGamePage({required this.gameUrl, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(gameUrl));

    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          WebViewWidget(controller: controller),
          Positioned(
            width: 25,
            height: 25,
            left: 15,
            top: 20,
            child: FloatingActionButton(
              onPressed: onClose,
              backgroundColor: Colors.red,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
