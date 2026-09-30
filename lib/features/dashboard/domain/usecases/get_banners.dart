import 'package:nyxproject/features/dashboard/domain/entities/HomeBanner.dart';
import 'package:nyxproject/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetBanners {
  const GetBanners(this._repository);

  final DashboardRepository _repository;

  Future<List<HomeBanner>> call() => _repository.getBanners();
}
