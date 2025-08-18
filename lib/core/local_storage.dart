import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._prefs);
  final SharedPreferences _prefs;

  static const String _kToken = 'auth_token';
  static const String _kUserName = 'user_name';
  static const String _kUserMobile = 'user_mobile';

  Future<void> saveToken(String token) async {
    await _prefs.setString(_kToken, token);
  }

  String? readToken() {
    return _prefs.getString(_kToken);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_kToken);
  }

  Future<void> saveUserName(String name) async {
    await _prefs.setString(_kUserName, name);
  }

  String? readUserName() => _prefs.getString(_kUserName);

  Future<void> saveUserMobile(String mobile) async {
    await _prefs.setString(_kUserMobile, mobile);
  }

  String? readUserMobile() => _prefs.getString(_kUserMobile);

  Future<void> clearUser() async {
    await _prefs.remove(_kUserName);
    await _prefs.remove(_kUserMobile);
  }
}


