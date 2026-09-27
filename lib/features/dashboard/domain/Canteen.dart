class Canteen {
  final int id;
  final String categoryName;
  final String name;
  final String price;
  final String imageUrl;
  final bool available;

  Canteen({
    required this.id,
    required this.categoryName,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.available,
  });

  factory Canteen.fromJson(Map<String, dynamic> json) {
    return Canteen(
      id: json['id'] as int,
      categoryName: json['category_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      imageUrl: json['image_url']?.toString() ?? '',
      available: json['available'] == 'true' || json['available'] == true,
    );
  }
}