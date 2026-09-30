// lib/models/Training.dart
class Training {
  final int id;
  final String mainProgramBannerImageUrl;

  Training({
    required this.id,
    required this.mainProgramBannerImageUrl,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'] as int,
      mainProgramBannerImageUrl: json['main_program_banner_image_url']?.toString() ?? '',
    );
  }
}