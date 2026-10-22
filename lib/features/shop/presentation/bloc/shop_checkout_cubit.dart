import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/features/shop/domain/entities/shop_order_request.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_shop_payment_methods.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_shop_tax.dart';
import 'package:nyxproject/features/shop/domain/usecases/place_shop_order.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_checkout_state.dart';

class ShopCheckoutCubit extends Cubit<ShopCheckoutState> {
  ShopCheckoutCubit({
    required GetShopPaymentMethods getPaymentMethods,
    required GetShopTax getTax,
    required PlaceShopOrder placeOrder,
  }) : _getPaymentMethods = getPaymentMethods,
       _getTax = getTax,
       _placeOrder = placeOrder,
       super(const ShopCheckoutState());

  final GetShopPaymentMethods _getPaymentMethods;
  final GetShopTax _getTax;
  final PlaceShopOrder _placeOrder;

  Future<void> load({String? token}) async {
    await Future.wait<void>([_loadPaymentMethods(token: token), _loadTax()]);
  }

  Future<void> _loadPaymentMethods({String? token}) async {
    emit(
      state.copyWith(
        isLoadingPaymentMethods: true,
        clearPaymentMethodsError: true,
      ),
    );
    try {
      final paymentMethods = await _getPaymentMethods(token: token);
      emit(
        state.copyWith(
          paymentMethods: paymentMethods,
          isLoadingPaymentMethods: false,
          clearPaymentMethodsError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPaymentMethods: false,
          paymentMethodsError: AppErrorMessage.from(error),
        ),
      );
    }
  }

  Future<void> _loadTax() async {
    emit(state.copyWith(isLoadingTax: true, clearTaxError: true));
    try {
      final tax = await _getTax();
      emit(
        state.copyWith(
          taxRate: tax.tax.toDouble(),
          isLoadingTax: false,
          clearTaxError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingTax: false,
          taxRate: 5,
          taxError: AppErrorMessage.from(error),
        ),
      );
    }
  }

  Future<void> placeOrder(ShopOrderRequest request) async {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        isSubmitting: true,
        clearSubmitError: true,
        clearOrderResponse: true,
      ),
    );
    try {
      final response = await _placeOrder(request);
      emit(state.copyWith(isSubmitting: false, orderResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: AppErrorMessage.from(error),
        ),
      );
    }
  }
}
