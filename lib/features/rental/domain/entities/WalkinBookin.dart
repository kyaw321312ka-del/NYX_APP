class WalkinBookin {
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
  final List<WalkinItem> items;

  const WalkinBookin({
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

  factory WalkinBookin.fromJson(Map<String, dynamic> json) {
    final itemData = json['items'];
    return WalkinBookin(
      id: _toInt(json['id']) ?? 0,
      venueName: json['venue_name']?.toString() ?? '',
      courtName: json['court_name']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentImageUrl: json['payment_image_url']?.toString() ?? '',
      customer: json['Customer']?.toString() ?? '',
      createAt: json['create_at']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      courtFee: _toInt(json['Court_Fee']) ?? 0,
      total: _toInt(json['Total']) ?? 0,
      items: itemData is List
          ? itemData
              .whereType<Map<String, dynamic>>()
              .map(WalkinItem.fromJson)
              .toList()
          : const [],
    );
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class WalkinItem {
  final int? price;
  final int? total;
  final int? quantity;
  final String? equipment;

  const WalkinItem({this.price, this.total, this.quantity, this.equipment});

  factory WalkinItem.fromJson(Map<String, dynamic> json) {
    return WalkinItem(
      price: _toInt(json['price']),
      total: _toInt(json['total']),
      quantity: _toInt(json['quantity']),
      equipment: json['equipment']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
