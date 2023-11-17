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
    userInfoBox.put('isAutoLoadingEnabled', true);
  }

  static String getUsername() {
    return userInfoBox.get('username');
  }

  static String getRole() {
    return userInfoBox.get('role');
  }

  static void setIsAutoLoadingEnabled(bool isAutoLoadingEnabled) {
    userInfoBox.put('isAutoLoadingEnabled', isAutoLoadingEnabled);
  }

  static bool getIsAutoLoadingEnabled() {
    return userInfoBox.get('isAutoLoadingEnabled');
  }

  static void clearUserInfo() {
    userInfoBox.clear();
  }
}
