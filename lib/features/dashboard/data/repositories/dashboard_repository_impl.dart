import 'package:nyxproject/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:nyxproject/features/dashboard/domain/entities/home_banner.dart';
import 'package:nyxproject/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({DashboardRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? DashboardRemoteDataSourceImpl();

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<List<HomeBanner>> getBanners() => _remoteDataSource.getBanners();

  @override
  Future<List<Category>> getCategories() => _remoteDataSource.getCategories();

  @override
  Future<List<Product>> getProducts() => _remoteDataSource.getProducts();
}
