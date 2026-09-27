class RentalBooking {
  final int id;
  final String venueName;
  final String courtName;
  final String paymentMethod;
  final String paymentImageUrl;
  final String customer;
  final String createAt;
  final String date;
  final int courtFee;
  final int total;
  final List<RentalItem> items;

  RentalBooking({
    required this.id,
    required this.venueName,
    required this.courtName,
    required this.paymentMethod,
    required this.paymentImageUrl,
    required this.customer,
    required this.createAt,
    required this.date,
    required this.courtFee,
    required this.total,
    required this.items,
  });

  factory RentalBooking.fromJson(Map<String, dynamic> json) {
    List<RentalItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      itemList = (json['items'] as List)
          .map((item) => RentalItem.fromJson(item))
          .toList();
    }
    
    return RentalBooking(
      id: _toInt(json['booking_id'] ?? json['id']) ?? 0,
      venueName: json['venue_name']?.toString() ?? '',
      courtName: json['court_name']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentImageUrl: json['payment_image_url']?.toString() ?? '',
      customer: json['Customer']?.toString() ?? '',
      createAt: json['create_at']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      courtFee: _toInt(json['Court_Fee']) ?? 0,
      total: _toInt(json['Total']) ?? 0,
      items: itemList,
    );
  }
  
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class RentalItem {
  final int? price;
  final int? total;
  final int? quantity;
  final String? equipment;

  RentalItem({
    this.price,
    this.total,
    this.quantity,
    this.equipment,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      price: _toInt(json['price']),
      total: _toInt(json['total']),
      quantity: _toInt(json['quantity']),
      equipment: json['equipment']?.toString(),
    );
  }
  
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}