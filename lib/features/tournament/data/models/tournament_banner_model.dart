import 'package:nyxproject/features/tournament/domain/entities/tournament_banner.dart';

class TournamentBannerModel extends TournamentBanner {
  const TournamentBannerModel({
    required super.id,
    required super.imagePath,
    super.createdAt,
    super.updatedAt,
  });

  factory TournamentBannerModel.fromJson(Map<String, dynamic> json) {
    return TournamentBannerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imagePath: json['image_path']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}
