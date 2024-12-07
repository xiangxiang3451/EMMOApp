import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmo/authentication/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 获取 Firestore 中某个用户的数据
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // 更新用户数据
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  // 添加新的用户数据
  Future<void> addNewUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data);
    } catch (e) {
      print("Error adding new user: $e");
    }
  }

  // 用户登出
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // 获取验证码并保存到 Firestore
  Future<void> saveVerificationCodeToFirebase(
      String email, String verificationCode) async {
    try {
      final userRef = _firestore.collection('users').doc(email);
      await userRef.set({
        'verification_code': verificationCode,
        'email': email,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving verification code to Firestore: $e');
    }
  }

  // 验证验证码
  Future<bool> verifyCode(String email, String code) async {
    try {
      final userRef = _firestore.collection('users').doc(email);
      final doc = await userRef.get();
      if (doc.exists) {
        final storedCode = doc.data()?['verification_code'];
        return storedCode == code;
      }
      return false;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  // 检查用户是否已经存在
  Future<bool> checkUserExists(String email) async {
    try {
      final userRef = _firestore.collection('users').doc(email);
      final doc = await userRef.get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // 注册/登录新用户
  Future<bool> registerNewUser(String email) async {
    try {
      final userRef = _firestore.collection('users').doc(email);
      await userRef.set({
        'email': email,
        'verification_code': '', // 清空验证码字段
      });
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  /// 将情绪记录保存到 Firestore
  Future<void> saveEmotionRecord({
    required String address,
    required String thoughts,
    required String date,
    required String weekday,
    required String expression,
    required Color color,
    File? photoFile, // 可选图片
  }) async {
    try {
      // 获取当前用户
      String? currentUserEmail = AuthenticationService.currentUserEmail;

      if (currentUserEmail == null) {
        throw Exception("用户未登录，无法保存记录。");
      }

      // 将图片编码为 Base64 字符串（如果存在）
      String? base64Image;
      if (photoFile != null) {
        List<int> imageBytes = await photoFile.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      // 构建记录数据
      final Map<String, dynamic> recordData = {
        'userId': currentUserEmail, // 当前用户ID
        'address': address,
        'thoughts': thoughts,
        'date': date,
        'weekday': weekday,
        'time': DateTime.now().toIso8601String(),
        'photo': base64Image, // 图片编码（如果有）
        'expression': expression,
        'color': color.value,
      };

      // 保存到 Firestore 的 "record" 集合
      await _firestore.collection('record').add(recordData);
    } catch (e, stackTrace) {
      print("保存记录时出错: $e");

      // 抛出详细的异常信息
      throw Exception("无法保存情绪记录：$e\nStack Trace: $stackTrace");
    }
  }

  Future<void> saveChatSummary(String userEmail, String summary) async {
    String? currentUserEmail = AuthenticationService.currentUserEmail;

    try {
      final now = DateTime.now();
      await _firestore.collection('chatSummaries').add({
        'userId': currentUserEmail,
        'summary': summary,
        'timestamp': now.toIso8601String(),
      });
    } catch (error) {
      throw Exception('Failed to save chat summary: $error');
    }
  }

  /// 投递漂流瓶
  Future<void> createBottle(String content) async {
    String? currentUserEmail = AuthenticationService.currentUserEmail;
    
    if (currentUserEmail == null) {
      throw Exception("用户未登录");
    }

    final bottle = {
      "content": content,
      "author_id": currentUserEmail,
      "created_at": DateTime.now().toIso8601String(),
      "status": "open", // 默认状态为 open
    };

    try {
      await FirebaseFirestore.instance.collection('bottles').add(bottle);
      print("漂流瓶已投出！");
    } catch (e) {
      print("创建漂流瓶失败：$e");
      throw e;
    }
  }

  Future<Map<String, dynamic>?> pickBottle() async {
  try {
    // 获取当前用户的 UID
    String? currentUserEmail = AuthenticationService.currentUserEmail;
    if (currentUserEmail == null) {
      print("用户未登录");
      return null;
    }

    // 获取所有状态为 open 且不是当前用户投放的漂流瓶
    final querySnapshot = await FirebaseFirestore.instance
        .collection('bottles')
        .where("status", isEqualTo: "open")
        .where("author_id", isNotEqualTo: currentUserEmail) // 过滤掉当前用户自己的漂流瓶
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // 随机挑选一个漂流瓶
      final random = Random();
      final randomDoc = querySnapshot.docs[random.nextInt(querySnapshot.docs.length)];
      return {
        "id": randomDoc.id, // 文档 ID
        "content": randomDoc["content"],
        "author_id": randomDoc["author_id"],
      };
    } else {
      print("没有更多的漂流瓶可拾取！");
      return null;
    }
  } catch (e) {
    print("拾取漂流瓶失败：$e");
    return null;
  }
}

Future<void> respondToBottle(String bottleId, String responseContent) async {
  String? currentUserEmail = AuthenticationService.currentUserEmail;

  if (currentUserEmail == null) {
    throw Exception("用户未登录");
  }

  final response = {
    "bottle_id": bottleId,
    "responder_id": currentUserEmail,
    "response_content": responseContent,
    "created_at": DateTime.now().toIso8601String(),
  };

  try {
    // 添加回应
    await FirebaseFirestore.instance.collection('responses').add(response);

    // 更新漂流瓶状态为 responded
    await FirebaseFirestore.instance.collection('bottles').doc(bottleId).update({
      "status": "responded",
    });

    print("回应已发送！");
  } catch (e) {
    print("回应失败：$e");
    throw e;
  }
}

}
