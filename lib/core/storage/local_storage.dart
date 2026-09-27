import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  bool? getBool(String key) => _preferences?.getBool(key);

  String? getString(String key) => _preferences?.getString(key);

  int? getInt(String key) => _preferences?.getInt(key);

  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }
}
