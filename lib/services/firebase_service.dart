import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 获取当前登录的用户
  User? getCurrentUser() {
    return _auth.currentUser;
  }

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

  // 注册新用户（使用 Firebase Authentication）
  Future<User?> registerUserWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error registering user: $e");
      return null;
    }
  }

  // 用户登录
  Future<User?> loginUserWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error logging in user: $e");
      return null;
    }
  }

  // 用户登出
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // 获取验证码并保存到 Firestore
  Future<void> saveVerificationCodeToFirebase(String email, String verificationCode) async {
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

  // 注册新用户
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
}
