import 'package:nyxproject/features/shop/domain/entities/tax.dart';
import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';

class GetShopTax {
  const GetShopTax(this._repository);

  final ShopRepository _repository;

  Future<Tax> call() => _repository.getTax();
}
