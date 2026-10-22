import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final ShopRepository _repository;

  Future<List<Category>> call() => _repository.getCategories();
}
