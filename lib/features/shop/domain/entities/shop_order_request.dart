import 'dart:io';

class ShopOrderRequest {
  const ShopOrderRequest({
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.deliveryAddress,
    required this.remark,
    required this.paymentMethod,
    required this.items,
    required this.tax,
    required this.totalAmount,
    required this.token,
    this.transactionNumber,
    this.transactionImage,
  });

  final int userId;
  final String customerName;
  final String phone;
  final String email;
  final String deliveryAddress;
  final String remark;
  final String paymentMethod;
  final List<Map<String, dynamic>> items;
  final double tax;
  final double totalAmount;
  final String? token;
  final String? transactionNumber;
  final File? transactionImage;
}
