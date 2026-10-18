import 'package:nyxproject/features/dashboard/data/datasources/home_banner_api.dart';
import 'package:nyxproject/features/dashboard/domain/entities/home_banner.dart';
import 'package:nyxproject/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<List<HomeBanner>> getBanners() => HomeBannerApi.getBanners();
}
