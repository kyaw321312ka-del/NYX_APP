import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/features/orders/data/datasources/OrderApi.dart';
import 'package:nyxproject/features/orders/domain/entities/Order.dart';
import 'package:nyxproject/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  @override
  Future<List<Order>> getOrderHistory({
    required int userId,
    String? token,
  }) async {
    final result = await OrderApi.fetchOrders(userId: userId, token: token);
    if (result['success'] != true || result['data'] is! List) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load orders',
      );
    }

    return (result['data'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();
  }
}
