import 'dart:math';
import 'package:emmo/services/firebase_service.dart';
import 'package:emmo/utils/constants.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AuthenticationService {
  static final FirebaseService _firebaseService = FirebaseService();
 // 全局变量，保存当前的登录用户
  static String? currentUserEmail; 
  // 生成验证码并发送邮件
  static Future<bool> sendVerificationCode(String email) async {
    try {
      String verificationCode = _generateVerificationCode();
      bool emailSent = await _sendEmailVerification(email, verificationCode);

      if (emailSent) {
        // 将验证码保存到 Firestore
        await _firebaseService.saveVerificationCodeToFirebase(email, verificationCode);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error sending verification code: $e');
      return false;
    }
  }

  // 生成6位随机验证码
  static String _generateVerificationCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // 发送验证码邮件
  static Future<bool> _sendEmailVerification(String email, String verificationCode) async {
    try {
      final smtpServer = _getGmailSmtpServer();
      final message = Message()
        ..from = Address('$mail') 
        ..recipients.add(email)
        ..subject = 'Your Verification Code'
        ..text = 'Your verification code is: $verificationCode';

      final sendReport = await send(message, smtpServer);
      print('Email sent: ' + sendReport.toString());
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
      username: '$mail',  
      password: '$mailPassword',   
      ssl: false,   
      // startTls: true,  
    );
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
}
