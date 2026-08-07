import '../../../core/services/api_client.dart';
import '../../../core/services/auth_storage_service.dart';

class AuthService {
  /// Registers a new user account with FastAPI backend
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String currency = "INR",
  }) async {
    final response = await ApiClient.post("/auth/register", {
      "name": name,
      "email": email,
      "password": password,
      "currency": currency,
    });

    final token = response['access_token'] as String;
    await AuthStorageService.saveToken(token);

    final userObj = response['user'] as Map<String, dynamic>;
    await AuthStorageService.saveUserData({
      "name": userObj['name'] ?? '',
      "email": userObj['email'] ?? '',
      "currency": userObj['currency'] ?? 'INR',
    });

    return response;
  }

  /// Authenticates user credentials with FastAPI backend
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post("/auth/login", {
      "email": email,
      "password": password,
    });

    final token = response['access_token'] as String;
    await AuthStorageService.saveToken(token);

    final userObj = response['user'] as Map<String, dynamic>;
    await AuthStorageService.saveUserData({
      "name": userObj['name'] ?? '',
      "email": userObj['email'] ?? '',
      "currency": userObj['currency'] ?? 'INR',
    });

    return response;
  }

  /// Fetches current user profile from GET /auth/me
  static Future<Map<String, dynamic>> fetchProfile() async {
    final response = await ApiClient.get("/auth/me");
    if (response is Map<String, dynamic>) {
      await AuthStorageService.saveUserData({
        "name": response['name'] ?? '',
        "email": response['email'] ?? '',
        "currency": response['currency'] ?? 'INR',
      });
    }
    return response;
  }

  /// Clears stored token & user credentials
  static Future<void> logout() async {
    try {
      await ApiClient.post("/auth/logout", {});
    } catch (_) {}
    await AuthStorageService.clearToken();
  }
}
