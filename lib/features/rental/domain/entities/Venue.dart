class Venue {
  final int id;
  final String venueName;
  final int price;
  final String venueImageUrl;
  final bool available;

  Venue({
    required this.id,
    required this.venueName,
    required this.price,
    required this.venueImageUrl,
    required this.available,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as int,
      venueName: json['venue_name']?.toString() ?? '',
      price: json['price'] as int? ?? 0,
      venueImageUrl: json['venue_image_url']?.toString() ?? '',
      available: json['available'] == true || json['available'] == 1,
    );
  }
}