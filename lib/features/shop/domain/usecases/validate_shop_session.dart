import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';

class ValidateShopSession {
  const ValidateShopSession(this._repository);

  final ShopRepository _repository;

  Future<bool> call({required String token}) =>
      _repository.validateSession(token: token);
}
