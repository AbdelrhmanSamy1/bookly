import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class TokenStorage {
  const TokenStorage._();

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
    required String role,
    required String firstName,
    required String lastName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kAccessTokenKey, accessToken);
    await prefs.setString(kRefreshTokenKey, refreshToken);
    await prefs.setString(kUserEmailKey, email);
    await prefs.setString(kUserRoleKey, role);
    await prefs.setString(kUserFirstNameKey, firstName);
    await prefs.setString(kUserLastNameKey, lastName);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kAccessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kRefreshTokenKey);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(kUserEmailKey),
      'role': prefs.getString(kUserRoleKey),
      'firstName': prefs.getString(kUserFirstNameKey),
      'lastName': prefs.getString(kUserLastNameKey),
    };
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kAccessTokenKey);
    await prefs.remove(kRefreshTokenKey);
    await prefs.remove(kUserEmailKey);
    await prefs.remove(kUserRoleKey);
    await prefs.remove(kUserFirstNameKey);
    await prefs.remove(kUserLastNameKey);
  }

  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
