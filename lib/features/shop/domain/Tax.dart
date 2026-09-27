class Tax {
  final int id;
  final int tax;

  Tax({
    required this.id,
    required this.tax,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'],
      tax: json['tax'],
    );
  }
}