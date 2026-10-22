import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/core/network/api_client.dart';
import 'package:nyxproject/features/shop/data/datasources/getallproduct_api.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/entities/shop_order_request.dart';
import 'package:nyxproject/features/shop/domain/entities/tax.dart';
import 'package:nyxproject/features/orders/data/datasources/order_api.dart';
import 'package:nyxproject/features/orders/data/datasources/payment_api.dart';
import 'package:nyxproject/features/orders/domain/entities/payment.dart';
import 'package:nyxproject/features/shop/data/datasources/tax_api.dart';

abstract interface class ShopRemoteDataSource {
  Future<bool> validateSession({required String token});

  Future<List<Product>> getProducts();

  Future<List<Category>> getCategories();

  Future<List<PaymentMethod>> getPaymentMethods({String? token});

  Future<Tax> getTax();

  Future<Map<String, dynamic>> placeOrder(ShopOrderRequest request);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  @override
  Future<bool> validateSession({required String token}) async {
    final result = await Api.getMyProfile(token: token);
    return result['unauthorized'] != true && result['success'] != false;
  }

  @override
  Future<List<Product>> getProducts() async {
    final result = await GetallproductApi.getAllProducts();
    if (result['success'] != true || result['data'] is! List<Product>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load products',
      );
    }
    return result['data'] as List<Product>;
  }

  @override
  Future<List<Category>> getCategories() async {
    final result = await Api.getAllCategories();
    if (result['success'] != true || result['data'] is! List<Category>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load categories',
      );
    }
    return result['data'] as List<Category>;
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods({String? token}) async {
    final result = await PaymentApi.getPaymentMethods(token: token);
    if (result['success'] != true || result['data'] is! List<PaymentMethod>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load payment methods',
      );
    }
    return result['data'] as List<PaymentMethod>;
  }

  @override
  Future<Tax> getTax() async {
    final result = await TaxApi.getTax();
    if (result['success'] != true || result['tax'] is! Tax) {
      throw ApiException(result['message']?.toString() ?? 'Failed to load tax');
    }
    return result['tax'] as Tax;
  }

  @override
  Future<Map<String, dynamic>> placeOrder(ShopOrderRequest request) async {
    final result = await OrderApi.placeOrder(
      userId: request.userId,
      customerName: request.customerName,
      phone: request.phone,
      email: request.email,
      deliveryAddress: request.deliveryAddress,
      remark: request.remark,
      paymentMethod: request.paymentMethod,
      items: request.items,
      tax: request.tax,
      deliveryFee: 0,
      transactionImage: request.transactionImage,
      transactionNumber: request.transactionNumber,
      token: request.token,
      totalAmount: request.totalAmount,
    );
    if (result['success'] != true) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to place order',
      );
    }
    return result;
  }
}
