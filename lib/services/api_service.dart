import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // FIXED: Direct URL to your Laravel backend
  // Change this port to match your Laravel server
  static const String BASE_URL = 'http://localhost:8000/api';
  
  // Alternative if localhost doesn't work:
  // static const String BASE_URL = 'http://127.0.0.1:8000/api';
  
  // For production, you would use:
  // static const String BASE_URL = 'https://yourdomain.com/api';

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/products'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          List products = data['products'];
          return products.map((data) => Product.fromJson(data)).toList();
        }
        throw Exception(data['message'] ?? 'Failed to load products');
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
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

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load collection');
      }
    } catch (e) {
      print('❌ GetCollection Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/categories'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          List categories = data['categories'];
          return categories.map((c) => c['name'].toString()).toList();
        }
        throw Exception(data['message'] ?? 'Failed to load categories');
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('❌ GetCategories Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 Register URL: $BASE_URL/register');
    print('📝 Name: $name');
    print('📝 Email: $email');
    print('📝 Phone: $phone');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
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

      print('✅ Status Code: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Server returned empty response. Make sure Laravel is running at $BASE_URL');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true) {
          return data['data'];
        }
        throw Exception(data['message'] ?? 'Failed to register');
      } else if (response.statusCode == 422) {
        String errors = '';
        if (data['errors'] != null) {
          errors = data['errors'].toString();
        }
        throw Exception('Validation failed: ${data['message'] ?? errors}');
      } else {
        throw Exception(data['message'] ?? 'Registration failed (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Registration Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 Login URL: $BASE_URL/login');
    print('📝 Email: $email');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('✅ Status Code: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Server returned empty response. Make sure Laravel is running at $BASE_URL');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return data['data'];
        }
        throw Exception(data['message'] ?? 'Failed to login');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception(data['message'] ?? 'Login failed (${response.statusCode})');
      }
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
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Status ${response.statusCode}', 'raw': response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

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
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
        throw Exception(data['message'] ?? 'Failed to load bookings');
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
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
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
        throw Exception(data['message'] ?? 'Failed to schedule booking');
      } else {
        String errorMsg = 'Failed to schedule booking';
        try {
          final data = json.decode(response.body);
          errorMsg = data['message'] ?? data['error'] ?? errorMsg;
        } catch (_) {}
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } catch (e) {
      print('❌ ScheduleBooking Error: $e');
      rethrow;
    }
  }

  static Future<Product> createProduct(
    String token,
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(productData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return Product.fromJson(data['product']);
        }
        throw Exception(data['message'] ?? 'Failed to create product');
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ CreateProduct Error: $e');
      rethrow;
    }
  }

  static Future<Product> updateProduct(
    String token,
    int id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(productData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return Product.fromJson(data['product']);
        }
        throw Exception(data['message'] ?? 'Failed to update product');
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
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
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ DeleteProduct Error: $e');
      rethrow;
    }
  }
}