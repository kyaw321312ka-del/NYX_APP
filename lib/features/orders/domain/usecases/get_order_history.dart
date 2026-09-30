import 'package:nyxproject/features/orders/domain/entities/Order.dart';
import 'package:nyxproject/features/orders/domain/repositories/orders_repository.dart';

class GetOrderHistory {
  const GetOrderHistory(this._repository);

  final OrdersRepository _repository;

  Future<List<Order>> call({required int userId, String? token}) {
    return _repository.getOrderHistory(userId: userId, token: token);
  }
}
