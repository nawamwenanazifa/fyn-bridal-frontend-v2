import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'auth_service.dart';
import 'api_service.dart';

class OrderService {
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${AuthService.token}',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Create order from booking
  static Future<Order> createOrder({
    required int bookingId,
    required String paymentMethod,
    required String shippingAddress,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.BASE_URL}/orders'),
        headers: _headers,
        body: jsonEncode({
          'booking_id': bookingId,
          'payment_method': paymentMethod,
          'shipping_address': shippingAddress,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📦 Create Order Response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Order.fromJson(data['order']);
        }
        throw Exception(data['message'] ?? 'Failed to create order');
      }
      throw Exception('Failed to create order: ${response.statusCode}');
    } catch (e) {
      print('❌ CreateOrder Error: $e');
      rethrow;
    }
  }

  // Get all orders for current user
  static Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.BASE_URL}/orders'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List orders = data['orders'];
          return orders.map((o) => Order.fromJson(o)).toList();
        }
        throw Exception(data['message'] ?? 'Failed to load orders');
      }
      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      print('❌ GetOrders Error: $e');
      throw Exception('Network error: Could not connect to server');
    }
  }

  // Get single order
  static Future<Order> getOrder(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.BASE_URL}/orders/$orderId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Order.fromJson(data['order']);
        }
        throw Exception(data['message'] ?? 'Failed to load order');
      }
      throw Exception('Failed to load order: ${response.statusCode}');
    } catch (e) {
      print('❌ GetOrder Error: $e');
      rethrow;
    }
  }

  // Cancel order
  static Future<void> cancelOrder(int orderId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.BASE_URL}/orders/$orderId/cancel'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel order');
      }
    } catch (e) {
      print('❌ CancelOrder Error: $e');
      rethrow;
    }
  }
}