class PaymentMethod {
  final int id;
  final String paymentMethod;
  final String paymentName;
  final String paymentImageUrl;
  final String paymentNumber;

  PaymentMethod({
    required this.id,
    required this.paymentMethod,
    required this.paymentName,
    required this.paymentImageUrl,
    required this.paymentNumber,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentName: json['payment_name']?.toString() ?? '',
      paymentImageUrl: json['payment_image_url']?.toString() ?? '',
      paymentNumber: json['payment_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_method': paymentMethod,
      'payment_name': paymentName,
      'payment_image_url': paymentImageUrl,
      'payment_number': paymentNumber,
    };
  }
}