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

  static void setAuth(String newToken, Map<String, dynamic> newUser) {
    _token = newToken;
    _user = newUser;
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ User logged in:');
    print('   Name: ${_user?['name']}');
    print('   Email: ${_user?['email']}');
    print('   is_admin value: ${_user?['is_admin']}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static void logout() {
    _token = null;
    _user = null;
    print('👋 User logged out');
  }
  
  static void updateUser(Map<String, dynamic> updatedUser) {
    _user = updatedUser;
  }
}