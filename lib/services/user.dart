// user.dart
class User {
  // 私有构造函数
  User._privateConstructor();

  // 静态实例
  static final User _instance = User._privateConstructor();

  // 工厂构造函数返回静态实例
  factory User() {
    return _instance;
  }

  String? userId; // 用户 ID
  // String? email; // 用户邮箱
   String? avatarUrl;  // 添加头像URL字段
  
}
