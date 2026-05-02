import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for persisting data
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize shared preferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save a value
  Future<void> save(String key, dynamic value) async {
    try {
      await _initPrefs();
      if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      } else {
        // For complex objects, serialize to JSON string
        await _prefs!.setString(key, value.toString());
      }
    } catch (e) {
      throw Exception('Failed to save $key: $e');
    }
  }

  /// Get a value
  Future<dynamic> get(String key) async {
    try {
      await _initPrefs();
      return _prefs!.get(key);
    } catch (e) {
      throw Exception('Failed to get $key: $e');
    }
  }

  /// Get string value
  Future<String?> getString(String key) async {
    await _initPrefs();
    return _prefs!.getString(key);
  }

  /// Get boolean value
  Future<bool?> getBoolean(String key) async {
    await _initPrefs();
    return _prefs!.getBool(key);
  }

  /// Get int value
  Future<int?> getInt(String key) async {
    await _initPrefs();
    return _prefs!.getInt(key);
  }

  /// Delete a key
  Future<void> delete(String key) async {
    try {
      await _initPrefs();
      await _prefs!.remove(key);
    } catch (e) {
      throw Exception('Failed to delete $key: $e');
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await _initPrefs();
      await _prefs!.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
}
