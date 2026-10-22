import 'package:flutter/foundation.dart' show immutable;
import 'package:nyxproject/features/shop/domain/entities/product.dart';

enum ShopRelatedProductsStatus { initial, loading, success, failure }

@immutable
class ShopRelatedProductsState {
  const ShopRelatedProductsState({
    this.status = ShopRelatedProductsStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  final ShopRelatedProductsStatus status;
  final List<Product> products;
  final String? errorMessage;
}
