import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/features/shop/data/datasources/GetallproductApi.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
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
