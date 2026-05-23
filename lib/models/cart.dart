class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double productPrice;
  final String? productImage;
  final int quantity;
  final double subtotal;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.productImage,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      productPrice: json['product_price'].toDouble(),
      productImage: json['product_image'],
      quantity: json['quantity'],
      subtotal: json['subtotal'].toDouble(),
    );
  }

  double get total => productPrice * quantity;
}

class Cart {
  final int id;
  final List<CartItem> items;
  final double total;
  final int itemCount;

  Cart({
    required this.id,
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final cartData = json['cart'];
    return Cart(
      id: cartData['id'],
      items: (cartData['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      total: cartData['total'].toDouble(),
      itemCount: cartData['item_count'],
    );
  }

  String get formattedTotal => 'UGX ${total.toStringAsFixed(0)}';
}