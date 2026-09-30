class Product {
  final int id;
  final String productName;
  final int price;
  final int cost;
  final String description;
  final String warranty;
  final String rating;
  final String made;
  final String brand;
  final String category;
  final String images;
  final String publicIds;
  final String types;
  final String colors;
  final String sizes;
  final String weights;
  final String totalStock;
  final String status;
  final String? tags;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.cost,
    required this.description,
    required this.warranty,
    required this.rating,
    required this.made,
    required this.brand,
    required this.category,
    required this.images,
    required this.publicIds,
    required this.types,
    required this.colors,
    required this.sizes,
    required this.weights,
    required this.totalStock,
    required this.status,
    this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      productName: json['productName']?.toString() ?? '',
      price: json['price'] as int,
      cost: json['cost'] as int,
      description: json['description']?.toString() ?? '',
      warranty: json['warranty']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      made: json['made']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      images: json['images']?.toString() ?? '',
      publicIds: json['public_ids']?.toString() ?? '',
      types: json['types']?.toString() ?? '',
      colors: json['colors']?.toString() ?? '',
      sizes: json['sizes']?.toString() ?? '',
      weights: json['weights']?.toString() ?? '',
      totalStock: json['total_stock']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      tags: json['tags']?.toString(),
    );
  }
}