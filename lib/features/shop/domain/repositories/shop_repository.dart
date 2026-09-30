import 'package:nyxproject/features/shop/domain/entities/product.dart';

abstract class ShopRepository {
  Future<List<Product>> getProducts();
}
