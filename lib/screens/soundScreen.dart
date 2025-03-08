import 'package:emmo/main.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundScreen extends StatefulWidget {
  @override
  _SoundScreenState createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> with WidgetsBindingObserver {
  bool isPlaying = false;
  String selectedSound = '';
  int selectedTime = 5; // 默认倒计时 5 分钟
  int remainingTime = 0; // 剩余时间（秒）
  bool isTimerRunning = false;

  final List<String> sounds = [
    'sound1.mp3',
    'sound2.mp3',
    'sound3.mp3',
    'sound4.mp3',
    'sound5.mp3',
  ];

  final List<int> timerOptions = [5, 10, 15]; // 倒计时选项（分钟）

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 监听生命周期
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除监听
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 监听应用生命周期
    if (state == AppLifecycleState.paused) {
      // 应用进入后台时暂停播放
      pauseSound();
    } else if (state == AppLifecycleState.resumed) {
      // 应用回到前台时恢复播放
      if (isPlaying) {
        playSound(selectedSound);
      }
    }
  }

  Future<void> playSound(String sound) async {
    try {
      await globalAudioPlayer.setReleaseMode(ReleaseMode.loop); // 设置循环播放
      await globalAudioPlayer.play(AssetSource('assets/$sound'));
      setState(() {
        isPlaying = true;
        selectedSound = sound;
      });
    } catch (e) {
      print('播放声音时出错: $e');
    }
  }

  Future<void> stopSound() async {
    try {
      await globalAudioPlayer.stop();
      setState(() {
        isPlaying = false;
        selectedSound = '';
      });
    } catch (e) {
      print('停止声音时出错: $e');
    }
  }

  Future<void> pauseSound() async {
    try {
      await globalAudioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      print('暂停声音时出错: $e');
    }
  }

  void startTimer() {
    if (selectedSound.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择一个声音')),
      );
      return;
    }

    setState(() {
      isTimerRunning = true;
      remainingTime = selectedTime * 60; // 将分钟转换为秒
    });

    playSound(selectedSound);

    // 每秒更新一次倒计时
    Future.delayed(const Duration(seconds: 1), () {
      updateTimer();
    });
  }

  void updateTimer() {
    if (remainingTime > 0 && isTimerRunning) {
      setState(() {
        remainingTime--;
      });
      Future.delayed(const Duration(seconds: 1), () {
        updateTimer();
      });
    } else {
      stopSound();
      setState(() {
        isTimerRunning = false;
      });
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.orange[50], // 背景暖色调
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '选择声音',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: sounds.map((sound) {
                return ChoiceChip(
                  label: Text(sound.replaceAll('.mp3', '')),
                  selected: selectedSound == sound,
                  onSelected: (selected) {
                    setState(() {
                      selectedSound = selected ? sound : '';
                    });
                  },
                  selectedColor: Colors.orange[300],
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: selectedSound == sound ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            const Text(
              '选择倒计时',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: timerOptions.map((time) {
                return ChoiceChip(
                  label: Text('$time 分钟'),
                  selected: selectedTime == time,
                  onSelected: (selected) {
                    setState(() {
                      selectedTime = selected ? time : 5;
                    });
                  },
                  selectedColor: Colors.orange[300],
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: selectedTime == time ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            if (isTimerRunning)
              Text(
                '剩余时间: ${formatTime(remainingTime)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isTimerRunning ? null : startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[300],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '开始',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}