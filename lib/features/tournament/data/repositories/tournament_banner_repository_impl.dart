import 'package:nyxproject/features/tournament/data/datasources/tournament_banner_remote_data_source.dart';
import 'package:nyxproject/features/tournament/domain/entities/tournament_banner.dart';
import 'package:nyxproject/features/tournament/domain/repositories/tournament_banner_repository.dart';

class TournamentBannerRepositoryImpl implements TournamentBannerRepository {
  const TournamentBannerRepositoryImpl(this._remoteDataSource);

  final TournamentBannerRemoteDataSource _remoteDataSource;

  @override
  Future<List<TournamentBanner>> getBanners() =>
      _remoteDataSource.getBanners();
}
