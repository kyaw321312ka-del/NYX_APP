class Court {
  final int id;
  final int venueId;
  final String courtName;
  final int hourlyPrice;
  final String openAt;
  final String closeAt;
  final String aboutCourt;
  final List<TimeSlot>? timeSlots;
  final List<Gallery>? gallery;
  final List<ProCon>? pros;
  final List<ProCon>? cons;
  final List<Service>? services;
  final List<Rule>? rules;
  final List<Equipment>? equipment;

  Court({
    required this.id,
    required this.venueId,
    required this.courtName,
    required this.hourlyPrice,
    required this.openAt,
    required this.closeAt,
    required this.aboutCourt,
    this.timeSlots,
    this.gallery,
    this.pros,
    this.cons,
    this.services,
    this.rules,
    this.equipment,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as int,
      venueId: json['venue_id'] as int? ?? 1,
      courtName: json['court_name']?.toString() ?? '',
      hourlyPrice: json['hourly_price'] as int? ?? 0,
      openAt: json['open_at']?.toString() ?? '',
      closeAt: json['close_at']?.toString() ?? '',
      aboutCourt: json['about_court']?.toString() ?? '',
      timeSlots: json['time_slots'] != null
          ? (json['time_slots'] as List).map((e) => TimeSlot.fromJson(e)).toList()
          : null,
      gallery: json['gallery'] != null
          ? (json['gallery'] as List).map((e) => Gallery.fromJson(e)).toList()
          : null,
      pros: json['pros'] != null
          ? (json['pros'] as List).map((e) => ProCon.fromJson(e)).toList()
          : null,
      cons: json['cons'] != null
          ? (json['cons'] as List).map((e) => ProCon.fromJson(e)).toList()
          : null,
      services: json['services'] != null
          ? (json['services'] as List).map((e) => Service.fromJson(e)).toList()
          : null,
      rules: json['rules'] != null
          ? (json['rules'] as List).map((e) => Rule.fromJson(e)).toList()
          : null,
      equipment: json['equipment'] != null
          ? (json['equipment'] as List).map((e) => Equipment.fromJson(e)).toList()
          : null,
    );
  }
}

class TimeSlot {
  final int id;
  final String startTime;
  final String endTime;

  TimeSlot({required this.id, required this.startTime, required this.endTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as int,
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class Gallery {
  final String courtImageUrl;

  Gallery({required this.courtImageUrl});

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      courtImageUrl: json['court_image_url']?.toString() ?? '',
    );
  }
}

class ProCon {
  final String name;

  ProCon({required this.name});

  factory ProCon.fromJson(Map<String, dynamic> json) {
    return ProCon(
      name: json['name']?.toString() ?? '',
    );
  }
}

class Service {
  final String name;

  Service({required this.name});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name']?.toString() ?? '',
    );
  }
}

class Rule {
  final String name;
  final String detail;

  Rule({required this.name, required this.detail});

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      name: json['name']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
    );
  }
}

class Equipment {
  final int id;
  final int qtyTotal;
  final String productName;
  final int rentalPrice;

  Equipment({
    required this.id,
    required this.qtyTotal,
    required this.productName,
    required this.rentalPrice,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as int,
      qtyTotal: json['qty_total'] as int? ?? 0,
      productName: json['product_name']?.toString() ?? '',
      rentalPrice: json['rental_price'] as int? ?? 0,
    );
  }
}