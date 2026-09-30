import 'package:nyxproject/features/orders/domain/entities/Order.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrderHistory({required int userId, String? token});
}
