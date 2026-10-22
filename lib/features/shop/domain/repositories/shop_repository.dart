import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/entities/shop_order_request.dart';
import 'package:nyxproject/features/shop/domain/entities/tax.dart';
import 'package:nyxproject/features/orders/domain/entities/payment.dart';

abstract class ShopRepository {
  Future<bool> validateSession({required String token});

  Future<List<Product>> getProducts();

  Future<List<Category>> getCategories();

  Future<List<PaymentMethod>> getPaymentMethods({String? token});

  Future<Tax> getTax();

  Future<Map<String, dynamic>> placeOrder(ShopOrderRequest request);
}
