import 'package:nyxproject/features/shop/domain/entities/shop_order_request.dart';
import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';

class PlaceShopOrder {
  const PlaceShopOrder(this._repository);

  final ShopRepository _repository;

  Future<Map<String, dynamic>> call(ShopOrderRequest request) =>
      _repository.placeOrder(request);
}
