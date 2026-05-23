import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'auth_service.dart';

class ApiService {
  static const String BASE_URL = 'http://127.0.0.1:8000/api';

  // ==================== PRODUCTS ====================

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/products'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['products'] as List)
              .map((d) => Product.fromJson(d))
              .toList();
        }
        throw Exception(data['message'] ?? 'Failed to load products');
      }
      throw Exception('Failed to load products: ${response.statusCode}');
    } catch (e) {
      print('❌ GetProducts Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  static Future<Map<String, dynamic>> getCollection(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/collections/$type'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Failed to load collection');
    } catch (e) {
      print('❌ GetCollection Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  // ==================== CATEGORIES ====================

  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/categories'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['categories'] as List)
              .map((c) => c['name'].toString())
              .toList();
        }
        throw Exception(data['message'] ?? 'Failed to load categories');
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      print('❌ GetCategories Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  static Future<Map<String, dynamic>> getCategoriesRaw() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/categories'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'categories': []};
    } catch (e) {
      print('❌ GetCategoriesRaw Error: $e');
      return {'success': false, 'categories': []};
    }
  }

  // ==================== AUTHENTICATION ====================

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    print('📍 Register: $BASE_URL/register  |  $email');
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('✅ ${response.statusCode}  ${response.body}');
      if (response.body.isEmpty) throw Exception('Server returned empty response.');

      final data = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true) return data['data'];
        throw Exception(data['message'] ?? 'Failed to register');
      } else if (response.statusCode == 422) {
        throw Exception(
            'Validation failed: ${data['message'] ?? data['errors']}');
      }
      throw Exception(
          data['message'] ?? 'Registration failed (${response.statusCode})');
    } catch (e) {
      print('❌ Registration Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    print('📍 Login: $BASE_URL/login  |  $email');
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      print('✅ ${response.statusCode}  ${response.body}');
      if (response.body.isEmpty) throw Exception('Server returned empty response.');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      }
      
      throw Exception(data['message'] ?? 'Login failed (${response.statusCode})');
    } catch (e) {
      print('❌ Login Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> diagnosticPing() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/diagnostic'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'error': 'Status ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== BOOKINGS ====================

  static Future<List<dynamic>> getBookings(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) return data['data'];
        throw Exception(data['message'] ?? 'Failed to load bookings');
      }
      throw Exception('Failed to load bookings: ${response.statusCode}');
    } catch (e) {
      print('❌ GetBookings Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  static Future<Map<String, dynamic>> scheduleBooking(
    String token,
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(bookingData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) return data['data'];
        throw Exception(data['message'] ?? 'Failed to schedule booking');
      }
      String errorMsg = 'Failed to schedule booking';
      try {
        final data = json.decode(response.body);
        errorMsg = data['message'] ?? data['error'] ?? errorMsg;
      } catch (_) {}
      throw Exception('$errorMsg (${response.statusCode})');
    } catch (e) {
      print('❌ ScheduleBooking Error: $e');
      rethrow;
    }
  }

  // ==================== BOOK APPOINTMENT (NEW) ====================

  static Future<Map<String, dynamic>> bookAppointment({
    required String phone,
    required String email,
    required String serviceType,
    required String bookingDate,
    String? notes,
  }) async {
    try {
      print('📍 Booking Appointment: $BASE_URL/bookings');
      print('📦 Data: phone=$phone, email=$email, serviceType=$serviceType, bookingDate=$bookingDate');

      final response = await http.post(
        Uri.parse('$BASE_URL/bookings'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'email': email,
          'service_type': serviceType,
          'booking_date': bookingDate,
          'notes': notes ?? '',
        }),
      ).timeout(const Duration(seconds: 30));

      print('✅ Booking response status: ${response.statusCode}');
      print('✅ Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        }
        throw Exception(data['message'] ?? 'Failed to create booking');
      }
      
      // Try to parse error message
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create booking: ${response.statusCode}');
      } catch (_) {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ BookAppointment Error: $e');
      rethrow;
    }
  }

  // ==================== ADMIN PRODUCT MANAGEMENT ====================

  static Future<Product> createProduct(
    String token,
    Map<String, dynamic> productData, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$BASE_URL/products'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      productData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (imageBytes != null && imageName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
        ));
      } else if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);

      if (response.statusCode == 201 && result['success'] == true) {
        return Product.fromJson(result['product']);
      }
      throw Exception(result['message'] ?? 'Failed to create product');
    } catch (e) {
      print('❌ CreateProduct Error: $e');
      rethrow;
    }
  }

  static Future<Product> updateProduct(
    String token,
    int id,
    Map<String, dynamic> productData, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$BASE_URL/products/$id'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      productData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (imageBytes != null && imageName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
        ));
      } else if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);

      if (response.statusCode == 200 && result['success'] == true) {
        return Product.fromJson(result['product']);
      }
      throw Exception(result['message'] ?? 'Failed to update product');
    } catch (e) {
      print('❌ UpdateProduct Error: $e');
      rethrow;
    }
  }

  static Future<bool> deleteProduct(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      throw Exception('Failed to delete product: ${response.statusCode}');
    } catch (e) {
      print('❌ DeleteProduct Error: $e');
      rethrow;
    }
  }

  // ==================== ADMIN USER MANAGEMENT ====================

  static Future<List<dynamic>> getUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) return data['users'];
        throw Exception(data['message'] ?? 'Failed to load users');
      }
      throw Exception('Failed to load users: ${response.statusCode}');
    } catch (e) {
      print('❌ GetUsers Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  static Future<bool> deleteUser(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      throw Exception('Failed to delete user: ${response.statusCode}');
    } catch (e) {
      print('❌ DeleteUser Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> toggleUserStatus(
      String token, int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$BASE_URL/users/$id/toggle'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) return data['user'];
        throw Exception(data['message'] ?? 'Failed to toggle user status');
      }
      throw Exception('Failed to toggle user: ${response.statusCode}');
    } catch (e) {
      print('❌ ToggleUserStatus Error: $e');
      rethrow;
    }
  }

  // ==================== CHAT / MESSAGES ====================

  static Future<Map<String, dynamic>> getConversations(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/messages/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load conversations');
    } catch (e) {
      print('❌ GetConversations Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  static Future<Map<String, dynamic>> getMessages(
      String token, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/messages/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load messages');
    } catch (e) {
      print('❌ GetMessages Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  static Future<void> sendMessage(
      String token, int receiverId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/messages/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiver_id': receiverId,
          'message': message,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('❌ SendMessage Error: $e');
      rethrow;
    }
  }
}