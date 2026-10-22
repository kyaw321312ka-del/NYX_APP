import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_products.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_related_products_state.dart';

class ShopRelatedProductsCubit extends Cubit<ShopRelatedProductsState> {
  ShopRelatedProductsCubit({
    required GetProducts getProducts,
    required Product product,
  }) : _getProducts = getProducts,
       _product = product,
       super(const ShopRelatedProductsState());

  final GetProducts _getProducts;
  final Product _product;

  Future<void> load() async {
    emit(
      const ShopRelatedProductsState(status: ShopRelatedProductsStatus.loading),
    );
    try {
      final products = await _getProducts();
      final relatedProducts = products
          .where(
            (candidate) =>
                candidate.category == _product.category &&
                candidate.id != _product.id,
          )
          .take(4)
          .toList();
      emit(
        ShopRelatedProductsState(
          status: ShopRelatedProductsStatus.success,
          products: relatedProducts,
        ),
      );
    } catch (error) {
      emit(
        ShopRelatedProductsState(
          status: ShopRelatedProductsStatus.failure,
          errorMessage: AppErrorMessage.from(error),
        ),
      );
    }
  }
}
