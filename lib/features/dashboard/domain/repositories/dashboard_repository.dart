import 'package:nyxproject/features/dashboard/domain/entities/home_banner.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';

abstract class DashboardRepository {
  Future<List<HomeBanner>> getBanners();
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts();
}
