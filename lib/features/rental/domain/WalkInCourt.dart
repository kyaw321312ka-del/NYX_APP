class WalkInCourt {
  final int? venueId;
  final String venueName;
  final String courtName;
  final String? walkInPrice;
  final List<String> courtImages;
  final String status;
  final String? openAt;
  final String? closeAt;
  final int? capacity;
  final int? courtId;
  final int? walkInId;
  final int? bookedCount;
  final int? remainingCapacity;
  final List<WalkInEquipment> equipment;

  const WalkInCourt({
    required this.venueId,
    required this.venueName,
    required this.courtName,
    required this.walkInPrice,
    required this.courtImages,
    required this.status,
    required this.openAt,
    required this.closeAt,
    required this.capacity,
    required this.courtId,
    required this.walkInId,
    required this.bookedCount,
    required this.remainingCapacity,
    required this.equipment,
  });

  factory WalkInCourt.fromJson(Map<String, dynamic> json) {
    final price = json['walk_in_price'];
    final images = json['court_images'];
    final equipmentData =
        json['equipment'] ??
        json['equipments'] ??
        json['rental_equipment'] ??
        json['rental_items'];

    return WalkInCourt(
      venueId: (json['venue_id'] as num?)?.toInt(),
      venueName: json['venue_name']?.toString() ?? '',
      courtName: json['court_name']?.toString() ?? '',
      walkInPrice: price?.toString(),
      courtImages: images is List
          ? images.whereType<String>().toList()
          : const [],
      status: json['status']?.toString() ?? '',
      openAt: json['open_at']?.toString(),
      closeAt: json['close_at']?.toString(),
      capacity: (json['capacity'] as num?)?.toInt(),
      courtId: (json['court_id'] as num?)?.toInt(),
      walkInId: (json['walk_in_id'] as num?)?.toInt(),
      bookedCount: (json['booked_count'] as num?)?.toInt(),
      remainingCapacity: (json['remaining_capacity'] as num?)?.toInt(),
      equipment: _parseEquipment(equipmentData),
    );
  }

  static List<WalkInEquipment> _parseEquipment(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map<String, dynamic>>()
        .map(WalkInEquipment.fromJson)
        .where((item) => item.name.isNotEmpty)
        .toList();
  }
}

class WalkInEquipment {
  final String name;
  final String price;
  final int maxQuantity;
  final int? id;

  const WalkInEquipment({
    required this.name,
    required this.price,
    required this.maxQuantity,
    required this.id,
  });

  factory WalkInEquipment.fromJson(Map<String, dynamic> json) {
    final price = json['rental_price'] ?? json['price'];
    final quantity =
        json['qty_total'] ??
        json['quantity'] ??
        json['max_qty'] ??
        json['max_quantity'] ??
        json['available_quantity'];

    return WalkInEquipment(
      name:
          (json['product_name'] ?? json['equipment_name'] ?? json['name'])
              ?.toString() ??
          '',
      price: price?.toString() ?? '0',
      maxQuantity: _toInt(quantity) ?? 99,
      id: _toInt(json['id'] ?? json['equipment_id']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
