import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ShopRepository _repository;

  Future<List<Product>> call() => _repository.getProducts();
}
