import 'dart:io';

class OrderItem {
  final int productId;
  final int quantity;
  
  OrderItem({
    required this.productId,
    required this.quantity,
  });
  
  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };
}

class OrderRequest {
  final int userId;
  final String customerName;
  final String phone;
  final String email;
  final String deliveryAddress;
  final String remark;
  final String paymentMethod;
  final List<OrderItem> items;
  final double tax;
  final double deliveryFee;
  final File? transactionImage;
  final String? transactionNumber;
  
  OrderRequest({
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.deliveryAddress,
    required this.remark,
    required this.paymentMethod,
    required this.items,
    required this.tax,
    required this.deliveryFee,
    this.transactionImage,
    this.transactionNumber,
  });
}

class Order {
  final int orderId;
  final DateTime createAt;
  final String orderStatus; 
  final String customerName;
  final List<OrderProduct> items;
  final double subTotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String? paymentMethod;
  final String? transactionNumber;
  final String? phone;
  final String? email;
  final String? deliveryAddress;
  final String? remark;

  Order({
    required this.orderId,
    required this.createAt,
    required this.orderStatus,
    required this.customerName,
    required this.items,
    required this.subTotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    this.paymentMethod,
    this.transactionNumber,
    this.phone,
    this.email,
    this.deliveryAddress,
    this.remark,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderProduct> items = [];
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((item) => OrderProduct.fromJson(item))
          .toList();
    }

    return Order(
      orderId: json['order_id'] as int,
      createAt: DateTime.parse(json['create_at']),
      orderStatus: json['order_status']?.toString() ?? 'pending',  
      customerName: json['customer_name']?.toString() ?? '',
      items: items,
      subTotal: (json['Sub_total'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      total: (json['Total'] ?? 0).toDouble(),
      paymentMethod: json['payment_method']?.toString(),
      transactionNumber: json['transaction_number']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      deliveryAddress: json['delivery_address']?.toString(),
      remark: json['remark']?.toString(),
    );
  }
}

class OrderProduct {
  final String productName;
  final int quantity;
  final double price;
  final double total;

  OrderProduct({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productName: json['product_name']?.toString() ?? '',
      quantity: json['quantity'] as int,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}