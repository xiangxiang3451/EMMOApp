import 'dart:convert';
import 'dart:math';
import 'package:emmo/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int selectedMood = 0;
  List<String> emotions = [
    "😊",
    "😔",
    "😡",
    "😱",
    "😴",
    "😂",
    "😢",
    "😍",
    "🤔",
    "😎",
    "🙃",
    "🥳",
  ];

  List<Color> moodColors = [
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.red[100]!,
    Colors.orange[100]!,
    Colors.pink[100]!,
    Colors.purple[100]!,
    Colors.yellow[100]!,
    Colors.cyan[100]!,
    Colors.teal[100]!,
    Colors.brown[100]!,
    Colors.lime[100]!,
    Colors.amber[100]!,
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
      backgroundColor: moodColors[selectedMood],
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
              style: TextStyle(
                  color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  getCurrentDate(),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  getCurrentWeekday(),
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
            // 表情以圆圈分布
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: List.generate(emotions.length, (index) {
                  final double angle = 2 * pi * index / emotions.length;
                  final double radius = 102;
                  final double x = radius * cos(angle);
                  final double y = radius * sin(angle);
                  return Positioned(
                    left: 150 + x,
                    top: 150 + y,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMood = index;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedMood == index
                              ? moodColors[index].withOpacity(0.8)
                              : moodColors[index].withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emotions[index],
                            style: const TextStyle(fontSize: 24),
                          ),
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
}


class NextPage extends StatefulWidget {
  final Color backgroundColor;

  const NextPage({super.key, required this.backgroundColor});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  String _selectedAddress = "自动获取地址或选择地址"; // 显示选中的地址

   @override
  void initState() {
    super.initState();
    // 页面加载时自动获取位置
    _getCurrentLocation();
  }
  Future<void> _getPermission() async {
  LocationPermission permission;

  // 检查是否已经授权
  permission = await Geolocator.checkPermission();

  // 如果未授权，发起请求
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // 用户永久拒绝权限
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  if (permission == LocationPermission.denied) {
    // 用户仅临时拒绝权限
    throw Exception('Location permissions are denied');
  }

  // 如果获取了权限，可以安全地调用位置方法
}

 Future<void> _getCurrentLocation() async {
  setState(() {
    _selectedAddress = "正在获取位置...";
  });

  try {
    // 创建LocationSettings对象
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // 设置为最佳导航精度
      distanceFilter: 10, // 每当设备移动超过10米时更新位置
    );

    // 获取当前位置
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings, // 使用LocationSettings
    );

    // 使用反向地理编码获取地址
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    // 构造完整的地址信息
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _selectedAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } else {
      setState(() {
        _selectedAddress = "未能解析地址";
      });
    }
  } catch (e) {
    // 错误处理
    setState(() {
      _selectedAddress = "获取位置失败: ${e.toString()}";
    });
  }
}

  // 打开地图选择页面
  Future<void> _openMapPicker() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (selectedLocation != null && selectedLocation is LatLng) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          selectedLocation.latitude,
          selectedLocation.longitude,
        );

        setState(() {
          _selectedAddress = placemarks.first.street ?? "未知位置";
        });
      } catch (e) {
        setState(() {
          _selectedAddress = "获取位置失败";
        });
      }
    }
  }

  // 获取当前日期
  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(now);
  }

  // 获取当前星期几
  String getCurrentWeekday() {
    final now = DateTime.now();
    final formatter = DateFormat.EEEE('en_US');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              '完成',
              style: TextStyle(
                  color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
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
                    '记录你的心情',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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
            GestureDetector(
              onTap: _openMapPicker, // 点击打开地图选择页面
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedAddress,
                        style: TextStyle(
                          color: _selectedAddress == "自动获取地址或选择地址"
                              ? Colors.grey[400]
                              : Colors.black,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.map, color: Colors.grey),
                  ],
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
                hintText: '输入你的想法...',
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

// 地图选择页面
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
    // _getCurrentLocation();
  }

  Future<void> _getInitialLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("用户拒绝位置权限");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("用户永久拒绝位置权限");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_selectedLocation!),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("选择位置"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
            child: const Text(
              "确认",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedLocation == null
              ? const Center(
                  child: Text("无法获取当前位置，请检查权限设置。"),
                )
              : GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  onTap: _onMapTapped,
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId("selected_location"),
                            position: _selectedLocation!,
                          )
                        }
                      : {},
                ),
    );
  }
}