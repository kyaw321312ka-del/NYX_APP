import 'package:nyxproject/features/dashboard/data/datasources/HomeBannerApi.dart';
import 'package:nyxproject/features/dashboard/domain/entities/HomeBanner.dart';
import 'package:nyxproject/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<List<HomeBanner>> getBanners() => HomeBannerApi.getBanners();
}
