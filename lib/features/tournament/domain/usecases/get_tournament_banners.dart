import 'package:nyxproject/features/tournament/domain/entities/tournament_banner.dart';
import 'package:nyxproject/features/tournament/domain/repositories/tournament_banner_repository.dart';

class GetTournamentBanners {
  const GetTournamentBanners(this._repository);

  final TournamentBannerRepository _repository;

  Future<List<TournamentBanner>> call() => _repository.getBanners();
}
