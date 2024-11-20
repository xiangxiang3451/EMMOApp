import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int selectedMood = 3; // 初始状态为“轻微开心”

  List<Color> moodColors = [
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.red[100]!,
    Colors.orange[100]!,
    Colors.pink[100]!,
    Colors.purple[100]!,
  ];

  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(now);
  }

  String getCurrentWeekday() {
    final now = DateTime.now();
    final formatter = DateFormat.EEEE('en_US');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: moodColors[selectedMood], // 根据选中的心情按钮改变背景色
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NextPage(
                    backgroundColor: moodColors[selectedMood],
                  ),
                ),
              );
            },
            child: const Text(
              'Next',
              style: TextStyle(color: Colors.green, fontSize: 18,fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mood, size: 30, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'How are you feeling now?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  getCurrentDate(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  getCurrentWeekday(),
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
            // 表情区域
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCuteEye(),
                    const SizedBox(width: 40),
                    _buildCuteEye(),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _buildMouth(),
                ),
              ],
            ),
            // 这里添加六个按钮，根据点击的按钮改变背景色
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        height: 10, // 控制按钮的高度
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedMood == index
                                ? moodColors[index]
                                : moodColors[index].withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(0), // 去掉默认内边距
                          ),
                          onPressed: () {
                            setState(() {
                              selectedMood = index;
                            });
                          },
                          child: Container(), // 这里只显示颜色
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 可爱的眼睛Widget
  Widget _buildCuteEye() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue[300],
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 10,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示不同嘴型的Widget
  Widget _buildMouth() {
    double curveFactor = (selectedMood - 2.5) * 0.8; // 控制嘴型的弧度
    return Container(
      width: 400,  // 增加嘴巴宽度
      height: 50,
      alignment: Alignment.center,
      child: CustomPaint(
        painter: MouthPainter(curveFactor),
      ),
    );
  }
}

// 自定义Painter绘制嘴型的横向弧度
class MouthPainter extends CustomPainter {
  final double curveFactor;
  MouthPainter(this.curveFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    const startX = 20.0;
    final endX = size.width - 20.0;
    final controlPoint = Offset(size.width / 2, size.height / 2 + curveFactor * 30);
    final path = Path()
      ..moveTo(startX, size.height / 2)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endX, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NextPage extends StatelessWidget {
  final Color backgroundColor;

  const NextPage({super.key, required this.backgroundColor});

  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(now);
  }

  String getCurrentWeekday() {
    final now = DateTime.now();
    final formatter = DateFormat.EEEE('en_US');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
       actions: [
          TextButton(
            onPressed: () {
              
            },
            child: const Text(
              'Finish',
              style: TextStyle(color: Colors.green, fontSize: 18,fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.mode, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Record your mood',
                    style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold, ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getCurrentDate(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  getCurrentWeekday(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: '自动获取地址或选择地址',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // 添加照片功能逻辑
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.photo_camera, size: 30, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your thoughts...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
