import 'package:nyxproject/features/dashboard/domain/entities/home_banner.dart';

abstract class DashboardRepository {
  Future<List<HomeBanner>> getBanners();
}
