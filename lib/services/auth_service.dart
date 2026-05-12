class AuthService {
  static String? token;
  static Map<String, dynamic>? user;

  static bool get isAuthenticated => token != null;

  static void setAuth(String newToken, Map<String, dynamic> newUser) {
    token = newToken;
    user = newUser;
  }

  static void logout() {
    token = null;
    user = null;
  }
}
