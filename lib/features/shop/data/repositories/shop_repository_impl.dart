import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/entities/shop_order_request.dart';
import 'package:nyxproject/features/shop/domain/entities/tax.dart';
import 'package:nyxproject/features/orders/domain/entities/payment.dart';
import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';
import 'package:nyxproject/features/shop/data/datasources/shop_remote_data_source.dart';

class ShopRepositoryImpl implements ShopRepository {
  ShopRepositoryImpl({ShopRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ShopRemoteDataSourceImpl();

  final ShopRemoteDataSource _remoteDataSource;

  @override
  Future<bool> validateSession({required String token}) =>
      _remoteDataSource.validateSession(token: token);

  @override
  Future<List<Product>> getProducts() => _remoteDataSource.getProducts();

  @override
  Future<List<Category>> getCategories() => _remoteDataSource.getCategories();

  @override
  Future<List<PaymentMethod>> getPaymentMethods({String? token}) =>
      _remoteDataSource.getPaymentMethods(token: token);

  @override
  Future<Tax> getTax() => _remoteDataSource.getTax();

  @override
  Future<Map<String, dynamic>> placeOrder(ShopOrderRequest request) =>
      _remoteDataSource.placeOrder(request);
}
