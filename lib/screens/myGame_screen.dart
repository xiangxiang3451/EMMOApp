import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebViewExample(),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    // 初始化 WebViewController
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // 启用 JavaScript
      ..setBackgroundColor(const Color(0x00000000)) // 设置背景透明
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // 在页面加载完成后注入 JavaScript 代码
            controller.runJavaScript(
              """
              // 设置视口
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
              document.getElementsByTagName('head')[0].appendChild(meta);

              // 获取游戏容器的元素
              var gameContainer = document.getElementById('game-container');
              if (gameContainer) {
                // 设置游戏容器的宽高为屏幕宽高
                gameContainer.style.width = '100%';
                gameContainer.style.height = '100%';
                gameContainer.style.position = 'absolute';
                gameContainer.style.top = '0';
                gameContainer.style.left = '0';
              }

              // 获取游戏画布的元素
              var gameCanvas = document.querySelector('canvas');
              if (gameCanvas) {
                // 设置画布的宽高为屏幕宽高
                gameCanvas.style.width = '100%';
                gameCanvas.style.height = '100%';
                gameCanvas.style.position = 'absolute';
                gameCanvas.style.top = '0';
                gameCanvas.style.left = '0';
              }
              """,
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://www.hoodamath.com/mobile/games/destress-game/game.html?nocheckorient=1')); // 加载 H5 游戏
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}