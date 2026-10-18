class HomeBanner {
  final int id;
  final String imagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HomeBanner({
    required this.id,
    required this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imagePath: json['image_path']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}
