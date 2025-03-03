import 'package:emmo/screens/driftBottlePage.dart';
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
      'url': 'https://www.hoodamath.com/mobile/games/piano-tiles/game.html?nocheckorient=1',
      'icon': Icons.videogame_asset,
    },
    {
      'name': 'Cubeform',
      'url': 'https://www.hoodamath.com/mobile/games/cubeform/game.html?nocheckorient=1',
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
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 游戏列表
            Row(
              children: games.map((game) {
                return GestureDetector(
                  onTap: () => _showGameFullScreen(game['url']),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Icon(game['icon'], size: 50, color: Colors.blue),
                        const SizedBox(height: 5),
                        Text(game['name']),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // 游戏下面的下划线
            const SizedBox(height: 20),
            // 邮箱子标题
            const Text(
              '邮箱',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            // 邮箱下划线
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 20),
            // 邮箱图标并点击进入邮箱界面
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>const DriftBottlePage (), // 替换成你想跳转的页面
                  ),
                );
              },
              child: const Icon(Icons.email, size: 50, color: Colors.blue),
            )
          ],
        ),
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
