import 'package:hive_flutter/hive_flutter.dart';

class UserInfo {
  static final userInfoBox = Hive.box('userInfo');

  static void setUserInfo(
    String username,
    String role,
    String fname,
    String lname,
  ) async {
    userInfoBox.put('username', username);
    userInfoBox.put('role', role);
    userInfoBox.put('fname', fname);
    userInfoBox.put('lname', lname);
  }

  static String getUsername() {
    return userInfoBox.get('username') ?? '';
  }

  static String getRole() {
    return userInfoBox.get('role');
  }

  static void clearUserInfo() {
    userInfoBox.clear();
  }
}
