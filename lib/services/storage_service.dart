/// Local storage service for persisting data
/// TODO: Implement with shared_preferences or hive
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // In-memory storage for now - replace with actual persistence
  final Map<String, dynamic> _store = {};

  /// Save a value
  Future<void> save(String key, dynamic value) async {
    try {
      // TODO: Implement with shared_preferences
      // await _prefs.setString(key, jsonEncode(value));
      _store[key] = value;
    } catch (e) {
      throw Exception('Failed to save $key: $e');
    }
  }

  /// Get a value
  dynamic get(String key) {
    try {
      // TODO: Implement with shared_preferences
      return _store[key];
    } catch (e) {
      throw Exception('Failed to get $key: $e');
    }
  }

  /// Get string value
  String? getString(String key) {
    return get(key) as String?;
  }

  /// Get boolean value
  bool? getBoolean(String key) {
    return get(key) as bool?;
  }

  /// Get int value
  int? getInt(String key) {
    return get(key) as int?;
  }

  /// Delete a key
  Future<void> delete(String key) async {
    try {
      // TODO: Implement with shared_preferences
      _store.remove(key);
    } catch (e) {
      throw Exception('Failed to delete $key: $e');
    }
  }

  /// Clear all storage
  Future<void> clear() async {
    try {
      // TODO: Implement with shared_preferences
      _store.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _store.containsKey(key);
  }
}
