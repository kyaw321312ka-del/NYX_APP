import 'package:nyxproject/features/orders/domain/entities/payment.dart';
import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';

class GetShopPaymentMethods {
  const GetShopPaymentMethods(this._repository);

  final ShopRepository _repository;

  Future<List<PaymentMethod>> call({String? token}) =>
      _repository.getPaymentMethods(token: token);
}
