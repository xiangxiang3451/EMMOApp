import 'dart:io';
import 'dart:math';
import 'package:emmo/screens/home_screen.dart';
import 'package:emmo/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
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
    Colors.blue[200]!,
    Colors.green[200]!,
    Colors.red[200]!,
    Colors.orange[200]!,
    Colors.pink[200]!,
    Colors.purple[200]!,
    Colors.yellow[200]!,
    Colors.cyan[200]!,
    Colors.teal[200]!,
    Colors.brown[200]!,
    Colors.lime[200]!,
    Colors.amber[200]!,
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
                    selectedEmotion: emotions[selectedMood], // 传递表情
                    selectedColor: moodColors[selectedMood], // 传递颜色,
                  ),
                ),
              );
            },
            child: const Text(
              'Next',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
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
                  const double radius = 102;
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
  final String selectedEmotion; // 接收表情
  final Color selectedColor; // 接收颜色

  const NextPage(
      {super.key, required this.selectedEmotion, required this.selectedColor});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  String _selectedAddress = "自动获取地址或选择地址"; // 显示选中的地址
  File? _selectedImage; // 存储选中或拍摄的照片
  final TextEditingController _textController = TextEditingController();

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
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
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
          _selectedAddress = "${place.street}, ${place.locality}";
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    // 处理返回的数据
    if (result != null && result is Map<String, dynamic>) {
      final LatLng? location = result['location'];
      final String? address = result['address'];

      if (location != null && address != null) {
        setState(() {
          _selectedAddress = address; // 更新地址
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

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      File? croppedImage = await _cropImage(File(photo.path));
      if (croppedImage != null) {
        setState(() {
          _selectedImage = croppedImage; // 保存裁剪后的图片
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File? croppedImage = await _cropImage(File(image.path));
      if (croppedImage != null) {
        setState(() {
          _selectedImage = croppedImage; // 保存裁剪后的图片
        });
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      // cropStyle: CropStyle.rectangle, // 裁剪样式
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪照片',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: false,
          lockAspectRatio: true,
          // 替换 aspectRatioPresets
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(
          title: '裁剪照片',
          aspectRatioLockEnabled: true,
          rectX: 0,
          rectY: 0,
        ),
      ],
    );
    return croppedImage != null ? File(croppedImage.path) : null;
  }

  Future<void> _onSaveButtonPressed() async {
    final firebaseService = FirebaseService();

    try {
      // 收集数据
      final String address = _selectedAddress;
      final String thoughts = _textController.text.trim();
      final String date = getCurrentDate();
      final String weekday = getCurrentWeekday();
      final File? photo = _selectedImage;
      final String expression =
          widget.selectedEmotion; // 假设 selectedEmotion 已经被选中
      final Color expressionColor =
          widget.selectedColor; // 假设 selectedColor 已经被选中

      // 调用 FirebaseService 存储记录
      await firebaseService.saveEmotionRecord(
        address: address,
        thoughts: thoughts,
        date: date,
        weekday: weekday,
        photoFile: photo,
        expression: expression,
        color: expressionColor,
      );

      // 提示成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('记录保存成功！')),
      );

      // 清空表单
      setState(() {
        _selectedAddress = "自动获取地址或选择地址";
        _selectedImage = null;
        _textController.clear();
      });
      // 跳转到目标界面（HomePage）
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const HomeScreen()), // 跳转到 HomePage
      );
    } catch (e) {
      // 显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.selectedColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _onSaveButtonPressed,
            child: const Text(
              'Finish',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
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
                    'Record your mood!',
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
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
                if (_selectedImage != null) {
                  // 弹出照片卡片
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(16.0),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null; // 删除照片
                                });
                                Navigator.pop(context); // 关闭弹窗
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('删除照片'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  // 弹出底部选择框
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt,
                                  color: Colors.blue),
                              title: const Text('拍摄照片'),
                              onTap: () {
                                Navigator.pop(context); // 关闭底部弹窗
                                _pickImageFromCamera(); // 调用拍摄照片方法
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library,
                                  color: Colors.green),
                              title: const Text('从相册选择'),
                              onTap: () {
                                Navigator.pop(context); // 关闭底部弹窗
                                _pickImageFromGallery(); // 调用相册选择方法
                              },
                            ),
                            ListTile(
                              leading:
                                  const Icon(Icons.cancel, color: Colors.red),
                              title: const Text('取消'),
                              onTap: () {
                                Navigator.pop(context); // 关闭底部弹窗
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                          ),
                        )
                      : const Icon(Icons.photo_camera,
                          size: 30, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
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
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isLoading = true;
  String _currentAddress = "点击地图上的位置以获取地址"; // 当前点击的地址

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

  void _onMapTapped(LatLng position) async {
    setState(() {
      _selectedLocation = position;
    });

    // 使用 Geocoding 包反向地理编码获取地址
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "${place.street}, ${place.locality}"; // 提取详细地址
        setState(() {
          _currentAddress = address; // 更新框中的地址显示
        });
      } else {
        setState(() {
          _currentAddress = "无法获取地址";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "获取地址失败: ${e.toString()}";
      });
    }
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
          : Column(
              children: [
                // 地址显示框
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          if (_currentAddress != "点击地图上的位置以获取地址") {
                            Navigator.pop(context, {
                              'location': _selectedLocation,
                              'address': _currentAddress,
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("请选择一个位置")),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GoogleMap(
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
                ),
              ],
            ),
    );
  }
}
