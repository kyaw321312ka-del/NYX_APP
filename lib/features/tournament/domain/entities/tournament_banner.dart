class TournamentBanner {
  final int id;
  final String imagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TournamentBanner({
    required this.id,
    required this.imagePath,
    this.createdAt,
    this.updatedAt,
  });
}
