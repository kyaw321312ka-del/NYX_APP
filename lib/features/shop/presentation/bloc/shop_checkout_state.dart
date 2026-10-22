import 'package:flutter/foundation.dart' show immutable;
import 'package:nyxproject/features/orders/domain/entities/payment.dart';

@immutable
class ShopCheckoutState {
  const ShopCheckoutState({
    this.paymentMethods = const [],
    this.isLoadingPaymentMethods = true,
    this.paymentMethodsError,
    this.taxRate = 5,
    this.isLoadingTax = true,
    this.taxError,
    this.isSubmitting = false,
    this.submitError,
    this.orderResponse,
  });

  final List<PaymentMethod> paymentMethods;
  final bool isLoadingPaymentMethods;
  final String? paymentMethodsError;
  final double taxRate;
  final bool isLoadingTax;
  final String? taxError;
  final bool isSubmitting;
  final String? submitError;
  final Map<String, dynamic>? orderResponse;

  ShopCheckoutState copyWith({
    List<PaymentMethod>? paymentMethods,
    bool? isLoadingPaymentMethods,
    String? paymentMethodsError,
    bool clearPaymentMethodsError = false,
    double? taxRate,
    bool? isLoadingTax,
    String? taxError,
    bool clearTaxError = false,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    Map<String, dynamic>? orderResponse,
    bool clearOrderResponse = false,
  }) {
    return ShopCheckoutState(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoadingPaymentMethods:
          isLoadingPaymentMethods ?? this.isLoadingPaymentMethods,
      paymentMethodsError: clearPaymentMethodsError
          ? null
          : paymentMethodsError ?? this.paymentMethodsError,
      taxRate: taxRate ?? this.taxRate,
      isLoadingTax: isLoadingTax ?? this.isLoadingTax,
      taxError: clearTaxError ? null : taxError ?? this.taxError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
      orderResponse: clearOrderResponse
          ? null
          : orderResponse ?? this.orderResponse,
    );
  }
}
