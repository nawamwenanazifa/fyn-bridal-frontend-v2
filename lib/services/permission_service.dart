// Removed dart:html import to avoid potential crashes on some platforms
// We will use a mock implementation for the preview environment

class PermissionService {
  static Future<bool> requestCamera() async {
    print('PermissionService: Camera Access Requested (Mock)');
    return true;
  }

  static Future<bool> requestMicrophone() async {
    print('PermissionService: Microphone Access Requested (Mock)');
    return true;
  }

  static Future<bool> requestLocation() async {
    print('PermissionService: Location Access Requested (Mock)');
    return true;
  }

  static Future<void> requestAll() async {
    await requestCamera();
    await requestMicrophone();
    await requestLocation();
  }
}
