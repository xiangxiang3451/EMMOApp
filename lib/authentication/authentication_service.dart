import 'dart:math';
import 'package:emmo/services/firebase_service.dart';
import 'package:emmo/utils/constants.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationService {
  static final FirebaseService _firebaseService = FirebaseService();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? currentUserEmail;
  static String? pairedUserEmail;

  // 生成6位随机验证码
  static String _generateVerificationCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // 发送验证码邮件
  static Future<bool> _sendEmailVerification(
      String email, String verificationCode) async {
    try {
      final smtpServer = _getGmailSmtpServer();
      final message = Message()
        ..from = const Address(mail)
        ..recipients.add(email)
        ..subject = 'Your Verification Code'
        ..text = 'Your verification code is: $verificationCode';

      final sendReport = await send(message, smtpServer);
      print('Email sent: $sendReport');
      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  // 获取 Gmail SMTP 服务器
  static SmtpServer _getGmailSmtpServer() {
    return SmtpServer(
      'smtp.gmail.com',
      port: 587,
      username: mail,
      password: mailPassword,
      ssl: false,
    );
  }

  // 发送验证码并保存到 Firestore
  static Future<bool> sendVerificationCode(String email) async {
    try {
      String verificationCode = _generateVerificationCode();
      bool emailSent = await _sendEmailVerification(email, verificationCode);

      if (emailSent) {
        // 将验证码保存到 Firestore
        await _firebaseService.saveVerificationCodeToFirebase(
            email, verificationCode);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error sending verification code: $e');
      return false;
    }
  }

  // 验证验证码
  static Future<bool> verifyCode(String email, String code) async {
    return await _firebaseService.verifyCode(email, code);
  }

  // 注册用户
  static Future<bool> registerUser(String email) async {
    return await _firebaseService.registerNewUser(email);
  }

  // 检查用户是否存在
  static Future<bool> checkUserExists(String email) async {
    return await _firebaseService.checkUserExists(email);
  }

  // 生成6位随机配对码
  static String _generatePairCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

// 生成并保存配对码（仅在用户注册或首次登录时调用）
  static Future<void> generateAndSavePairCode(String email) async {
    // 检查用户是否已经有配对码
    final userDoc = await _firestore.collection('users').doc(email).get();

    // 如果用户没有配对码，则生成并保存
    if (!userDoc.exists || userDoc.data()?['pairCode'] == null) {
      final pairCode = _generatePairCode(); // 生成新的配对码

      // 将配对码保存到 users 集合
      await _firestore.collection('users').doc(email).set({
        'pairCode': pairCode,
      }, SetOptions(merge: true)); // 使用 merge 避免覆盖其他字段
    }
  }

  // 用户登录逻辑
  static Future<bool> login(String email, String password) async {
    // 这里实现你的登录逻辑（例如 Firebase Authentication）
    // 假设登录成功
    currentUserEmail = email;

    // 登录成功后，动态生成并保存配对码
    await generateAndSavePairCode(email);

    // 登录成功后，加载配对信息
    await loadPairInfo();

    return true; // 登录成功
  }

  // 加载配对信息
  static Future<void> loadPairInfo() async {
    final currentUserEmail = AuthenticationService.currentUserEmail;
    if (currentUserEmail == null) return;

    final pairDoc = await _firestore.collection('pairs').doc(currentUserEmail).get();

    if (pairDoc.exists) {
      pairedUserEmail = pairDoc['pairedUserEmail'];
    }
  }

  // 通过配对码配对用户
  static Future<bool> pairUsers(String pairCode) async {
    final currentUserEmail = AuthenticationService.currentUserEmail;
    if (currentUserEmail == null) throw Exception('用户未登录');

    // 查询配对码对应的用户
    final querySnapshot = await _firestore
        .collection('users')
        .where('pairCode', isEqualTo: pairCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) throw Exception('配对码无效');

    // 获取对方用户邮箱
    final pairedUserEmail = querySnapshot.docs.first.id;

    // 将双方用户绑定到 pairs 集合
    await _firestore.collection('pairs').doc(currentUserEmail).set({
      'pairedUserEmail': pairedUserEmail,
    });

    await _firestore.collection('pairs').doc(pairedUserEmail).set({
      'pairedUserEmail': currentUserEmail,
    });

    // 更新本地状态
    AuthenticationService.pairedUserEmail = pairedUserEmail;

    return true;
  }

  // 获取配对用户
  static Future<String?> getPairedUserEmail() async {
    if (pairedUserEmail != null) return pairedUserEmail;

    final currentUserEmail = AuthenticationService.currentUserEmail;
    if (currentUserEmail == null) return null;

    final pairDoc = await _firestore.collection('pairs').doc(currentUserEmail).get();

    if (pairDoc.exists) {
      pairedUserEmail = pairDoc['pairedUserEmail'];
      return pairedUserEmail;
    }
    return null;
  }

  // 解除配对
  static Future<void> unpairUsers() async {
    final currentUserEmail = AuthenticationService.currentUserEmail;
    if (currentUserEmail == null) return;

    final pairedUserEmail = await getPairedUserEmail();
    if (pairedUserEmail == null) return;

    // 删除 pairs 集合中的配对信息
    await _firestore.collection('pairs').doc(currentUserEmail).delete();
    await _firestore.collection('pairs').doc(pairedUserEmail).delete();

    // 清除本地状态
    AuthenticationService.pairedUserEmail = null;
  }
}
