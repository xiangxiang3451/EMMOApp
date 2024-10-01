import 'package:emotion_recognition/models/constants.dart';
import 'package:emotion_recognition/services/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_screen.dart'; // 导入登录界面
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    // 不再需要加载头像，因为我们始终从数据库获取
  }

  // 弹出底部菜单，选择拍照或从相册选择
  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 选择头像或拍照功能
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
      // 上传头像
      await _uploadAvatar(image);
    }
  }

  // 上传头像到后端
  // 上传头像到后端
Future<void> _uploadAvatar(XFile image) async {
  final bytes = await image.readAsBytes();
  final base64Image = base64Encode(bytes);

  // 获取用户 ID
  String? userId = User().userId;

  try {
    final response = await http.post(
      Uri.parse('$BackEndUrl/upload_avatar'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'user_id': userId,
        'file': base64Image,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String newAvatarUrl = responseData['avatar_url']; // 获取新头像 URL

      // 更新状态以显示新头像
      setState(() {
        _profileImage = null; // 清除本地图像，以确保显示网络图像
      });

      // 更新用户的头像 URL
      User().avatarUrl = newAvatarUrl;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像上传成功！')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('头像上传失败: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('上传过程中发生错误: $e')),
    );
  }
}


  // 退出登录功能
  void _logout() {
    // 可以在这里执行一些清理工作，例如清除 token 等

    // 跳转回登录界面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
   String? avatarUrl = User().avatarUrl; // 获取用户头像 URL
  String imageUrl = (avatarUrl != null && avatarUrl.isNotEmpty)
      ? 'https://firebasestorage.googleapis.com/v0/b/emotion-recognition-c7d78.appspot.com/o/${Uri.encodeComponent(avatarUrl.replaceFirst('https://storage.googleapis.com/emotion-recognition-c7d78.appspot.com/', ''))}?alt=media'
      : ''; // 如果没有头像，则留空


    print(imageUrl);
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () {
                _showImageSourceActionSheet(context); // 点击头像时弹出选择菜单
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            // 当图像加载失败时显示错误信息
                            return Container(
                              color: Colors.red[200], // 背景颜色
                              child: const Center(
                                child: Text(
                                  '图像加载失败',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Icon(Icons.person, size: 50), // 如果没有头像，显示默认图标
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '点击头像进行更换',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const Divider(height: 40),
          _buildLogoutSection(), // 退出登录部分
          const Divider(height: 40),
          _buildPrivacySection(),
          const Divider(height: 40),
          _buildNotificationSection(),
          const Divider(height: 40),
          _buildLanguageSection(),
          const Divider(height: 40),
          _buildExportDataSection(),
        ],
      ),
    );
  }

  // 退出登录部分
  Widget _buildLogoutSection() {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('退出登录'),
      onTap: _logout, // 点击退出登录时调用
    );
  }

  // 隐私设置部分
  Widget _buildPrivacySection() {
    return ListTile(
      leading: const Icon(Icons.privacy_tip),
      title: const Text('隐私设置'),
      subtitle: const Text('管理情感数据存储和隐私'),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          // 跳转到隐私设置界面
        },
      ),
    );
  }

  // 通知设置部分
  Widget _buildNotificationSection() {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: const Text('通知设置'),
      subtitle: const Text('启用或禁用通知'),
      trailing: Switch(
        value: true, // 这里可以根据用户的设置状态动态改变
        onChanged: (bool value) {
          // 切换通知功能
        },
      ),
    );
  }

  // 语言设置部分
  Widget _buildLanguageSection() {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('语言设置'),
      subtitle: const Text('切换应用语言'),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          // 跳转到语言设置界面
        },
      ),
    );
  }

  // 数据导出部分
  Widget _buildExportDataSection() {
    return ListTile(
      leading: const Icon(Icons.file_download),
      title: const Text('导出数据'),
      subtitle: const Text('导出情感分析数据报告'),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          // 跳转到数据导出界面
        },
      ),
    );
  }
}
