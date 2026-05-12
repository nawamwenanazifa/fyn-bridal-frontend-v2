/// Extension for safe access to nullable maps
/// 
/// This allows you to safely access values from a nullable Map
/// without having to write null checks every time.
/// 
/// Example usage:
///   Map<String, dynamic>? user = AuthService.user;
///   String? name = user.get('name');  // Returns null if user is null
///   String? email = user.get('email');
extension SafeMapAccess on Map<String, dynamic>? {
  /// Safely get a value from the map
  /// Returns null if the map is null or the key doesn't exist
  dynamic get(String key) {
    return this != null ? this![key] : null;
  }
  
  /// Safely get a String value from the map
  String? getString(String key) {
    final value = get(key);
    return value?.toString();
  }
  
  /// Safely get an int value from the map
  int? getInt(String key) {
    final value = get(key);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
  
  /// Safely get a bool value from the map
  bool? getBool(String key) {
    final value = get(key);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }
  
  /// Safely get a List from the map
  List? getList(String key) {
    final value = get(key);
    return value is List ? value : null;
  }
  
  /// Safely get a Map from the map
  Map<String, dynamic>? getMap(String key) {
    final value = get(key);
    return value is Map<String, dynamic> ? value : null;
  }
}