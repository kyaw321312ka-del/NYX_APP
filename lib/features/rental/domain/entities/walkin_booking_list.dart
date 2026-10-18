class WalkinBookingList {
  final int userId;
  final int walkInId;
  final int bookingId;
  final String bookingName;
  final String phone;
  final String date;
  final String paymentImageUrl;
  final String time;
  final String venueName;
  final String courtName;
  final String paymentMethod;
  final int walkInPrice;
  final int equipmentPrice;
  final List<dynamic> equipment;
  final int amount;

  const WalkinBookingList({
    required this.userId,
    required this.walkInId,
    required this.bookingId,
    required this.bookingName,
    required this.phone,
    required this.date,
    required this.paymentImageUrl,
    required this.time,
    required this.venueName,
    required this.courtName,
    required this.paymentMethod,
    required this.walkInPrice,
    required this.equipmentPrice,
    required this.equipment,
    required this.amount,
  });

  factory WalkinBookingList.fromJson(Map<String, dynamic> json) {
    return WalkinBookingList(
      userId: _toInt(json['user_id']),
      walkInId: _toInt(json['walk_in_id']),
      bookingId: _toInt(json['booking_id']),
      bookingName: _toString(json['booking_name']),
      phone: _toString(json['phone']),
      date: _toString(json['date']),
      paymentImageUrl: _toString(json['payment_image_url']),
      time: _toString(json['time']),
      venueName: _toString(json['venue_name']),
      courtName: _toString(json['court_name']),
      paymentMethod: _toString(json['payment_method']),
      walkInPrice: _toInt(json['walk_in_price']),
      equipmentPrice: _toInt(json['equipment_price']),
      equipment: json['equipment'] is List
          ? json['equipment'] as List
          : const [],
      amount: _toInt(json['amount']),
    );
  }

  static String _toString(dynamic value) => value?.toString() ?? '';

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
