import 'package:nyxproject/features/dashboard/domain/entities/HomeBanner.dart';

abstract class DashboardRepository {
  Future<List<HomeBanner>> getBanners();
}
