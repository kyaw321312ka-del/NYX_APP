import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/core/network/api_client.dart';
import 'package:nyxproject/features/dashboard/data/datasources/home_banner_api.dart';
import 'package:nyxproject/features/dashboard/domain/entities/home_banner.dart';
import 'package:nyxproject/features/shop/data/datasources/getallproduct_api.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';

abstract interface class DashboardRemoteDataSource {
  Future<List<HomeBanner>> getBanners();
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<List<HomeBanner>> getBanners() => HomeBannerApi.getBanners();

  @override
  Future<List<Category>> getCategories() async {
    final result = await Api.getAllCategories();
    if (result['success'] != true || result['data'] is! List<Category>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load categories',
      );
    }
    return result['data'] as List<Category>;
  }

  @override
  Future<List<Product>> getProducts() async {
    final result = await GetallproductApi.getAllProducts();
    if (result['success'] != true || result['data'] is! List<Product>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load products',
      );
    }
    return result['data'] as List<Product>;
  }
}
