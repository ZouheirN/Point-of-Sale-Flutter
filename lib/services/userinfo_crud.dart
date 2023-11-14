import 'package:hive_flutter/hive_flutter.dart';

class UserInfo {
  static final userInfoBox = Hive.box('userInfo');

  static void setUserInfo(
    String username,
  ) async {
    userInfoBox.put('username', username);
  }

  static String getUsername() {
    return userInfoBox.get('username');
  }
}
