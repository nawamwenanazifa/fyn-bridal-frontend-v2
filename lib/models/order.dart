class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final String? productImage;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product']['name'] ?? '',
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      productImage: json['product']['image'],
    );
  }

  double get subtotal => quantity * price;
}

class Order {
  final int id;
  final String orderNumber;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String shippingAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.shippingAddress,
    this.notes,
    required this.createdAt,
    this.deliveredAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      subtotal: double.parse(json['subtotal'].toString()),
      tax: double.parse(json['tax'].toString()),
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      total: double.parse(json['total'].toString()),
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      orderStatus: json['order_status'],
      shippingAddress: json['shipping_address'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
    );
  }

  bool get isPending => orderStatus == 'pending';
  bool get isPaid => paymentStatus == 'paid';
  bool get isDelivered => orderStatus == 'delivered';
  bool get isCancelled => orderStatus == 'cancelled';

  String get formattedTotal => 'UGX ${total.toStringAsFixed(0)}';
  String get formattedOrderNumber => '#$orderNumber';
}