class AuthStorageService {
  static String? _inMemoryToken;
  static Map<String, String>? _inMemoryUser;

  static Future<void> saveToken(String token) async {
    _inMemoryToken = token;
  }

  static Future<String?> getToken() async {
    return _inMemoryToken;
  }

  static Future<void> clearToken() async {
    _inMemoryToken = null;
    _inMemoryUser = null;
  }

  static Future<void> saveUserData(Map<String, String> userData) async {
    _inMemoryUser = userData;
  }

  static Future<Map<String, String>?> getUserData() async {
    return _inMemoryUser;
  }
}
