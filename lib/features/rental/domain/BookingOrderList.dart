// lib/models/BookingOrder.dart
class BookingOrder {
  final int id;
  final int userId;
  final String venueName;
  final String courtName;
  final String paymentMethod;
  final String paymentImageUrl;
  final String customer;
  final String createAt;
  final String date;
  final int courtFee;
  final int total;
  final List<BookingItem> items;

  BookingOrder({
    required this.id,
    required this.userId,
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

  factory BookingOrder.fromJson(Map<String, dynamic> json) {
    List<BookingItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      itemList = (json['items'] as List)
          .map((item) => BookingItem.fromJson(item))
          .toList();
    }
    
    return BookingOrder(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      venueName: json['venue_name']?.toString() ?? '',
      courtName: json['court_name']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentImageUrl: json['payment_image_url']?.toString() ?? '',
      customer: json['Customer']?.toString() ?? '',
      createAt: json['create_at']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      courtFee: json['Court_Fee'] as int? ?? 0,
      total: json['Total'] as int? ?? 0,
      items: itemList,
    );
  }
}

class BookingItem {
  final int? price;
  final int? total;
  final int? quantity;
  final String? equipment;

  BookingItem({
    this.price,
    this.total,
    this.quantity,
    this.equipment,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      price: json['price'] as int?,
      total: json['total'] as int?,
      quantity: json['quantity'] as int?,
      equipment: json['equipment']?.toString(),
    );
  }
}