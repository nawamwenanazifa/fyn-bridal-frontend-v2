import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart.dart';
import 'auth_service.dart';
import 'api_service.dart';

class CartService {
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${AuthService.token}',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Get cart
  static Future<Cart> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.BASE_URL}/cart'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Cart.fromJson(data);
        }
        throw Exception(data['message'] ?? 'Failed to load cart');
      }
      throw Exception('Failed to load cart: ${response.statusCode}');
    } catch (e) {
      print('❌ GetCart Error: $e');
      rethrow;
    }
  }

  // Add item to cart
  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.BASE_URL}/cart/add'),
        headers: _headers,
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        }
        throw Exception(data['message'] ?? 'Failed to add to cart');
      }
      throw Exception('Failed to add to cart: ${response.statusCode}');
    } catch (e) {
      print('❌ AddToCart Error: $e');
      rethrow;
    }
  }

  // Update cart item quantity
  static Future<void> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.BASE_URL}/cart/item/$itemId'),
        headers: _headers,
        body: jsonEncode({'quantity': quantity}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to update cart');
      }
    } catch (e) {
      print('❌ UpdateCartItem Error: $e');
      rethrow;
    }
  }

  // Remove item from cart
  static Future<void> removeCartItem(int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.BASE_URL}/cart/item/$itemId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item');
      }
    } catch (e) {
      print('❌ RemoveCartItem Error: $e');
      rethrow;
    }
  }

  // Clear cart
  static Future<void> clearCart() async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.BASE_URL}/cart/clear'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to clear cart');
      }
    } catch (e) {
      print('❌ ClearCart Error: $e');
      rethrow;
    }
  }

  // Checkout
  static Future<Map<String, dynamic>> checkout({
    required String shippingAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.BASE_URL}/cart/checkout'),
        headers: _headers,
        body: jsonEncode({
          'shipping_address': shippingAddress,
          'payment_method': paymentMethod,
          'notes': notes ?? '',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        }
        throw Exception(data['message'] ?? 'Checkout failed');
      }
      throw Exception('Checkout failed: ${response.statusCode}');
    } catch (e) {
      print('❌ Checkout Error: $e');
      rethrow;
    }
  }
}