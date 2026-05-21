import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String? _token;
  static Map<String, dynamic>? _user;

  static String? get token => _token;
  static Map<String, dynamic>? get user => _user;
  
  static set user(Map<String, dynamic>? value) {
    _user = value;
  }

  static bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  
  static bool get isAdmin {
    if (_user == null) return false;
    final adminValue = _user!['is_admin'];
    return adminValue == true || adminValue == 1;
  }

  // Call this when your app starts to load saved data
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final String? userJson = prefs.getString('user_data');
      
      if (userJson != null && userJson.isNotEmpty) {
        _user = json.decode(userJson) as Map<String, dynamic>;
      }
      
      print('🔐 AuthService initialized. Token: ${_token != null ? "Yes (${_token!.substring(0, _token!.length > 20 ? 20 : _token!.length)}...)" : "No"}');
    } catch (e) {
      print('❌ AuthService init error: $e');
      _token = null;
      _user = null;
    }
  }

  static Future<void> setAuth(String newToken, Map<String, dynamic> newUser) async {
    _token = newToken;
    _user = newUser;
    
    // Save to persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', newToken);
      await prefs.setString('user_data', json.encode(newUser));
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ User logged in:');
      print('   Name: ${_user?['name']}');
      print('   Email: ${_user?['email']}');
      print('   is_admin value: ${_user?['is_admin']}');
      print('   Token saved to storage');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      print('❌ Failed to save auth data: $e');
    }
  }

  static Future<void> logout() async {
    _token = null;
    _user = null;
    
    // Clear persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      
      print('👋 User logged out and storage cleared');
    } catch (e) {
      print('❌ Failed to clear auth data: $e');
    }
  }
  
  static void updateUser(Map<String, dynamic> updatedUser) {
    _user = updatedUser;
  }
  
  // Helper method to check if token is valid
  static Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
}