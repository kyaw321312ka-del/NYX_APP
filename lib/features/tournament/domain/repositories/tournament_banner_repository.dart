import 'package:nyxproject/features/tournament/domain/entities/tournament_banner.dart';

abstract class TournamentBannerRepository {
  Future<List<TournamentBanner>> getBanners();
}
