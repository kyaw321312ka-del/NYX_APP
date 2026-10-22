import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/features/shop/domain/usecases/validate_shop_session.dart';

enum ShopSessionStatus { loading, valid, invalid }

@immutable
class ShopSessionState {
  const ShopSessionState({
    this.status = ShopSessionStatus.loading,
    this.shouldLogout = false,
    this.errorMessage,
  });

  final ShopSessionStatus status;
  final bool shouldLogout;
  final String? errorMessage;
}

class ShopSessionCubit extends Cubit<ShopSessionState> {
  ShopSessionCubit({required ValidateShopSession validateSession})
    : _validateSession = validateSession,
      super(const ShopSessionState());

  final ValidateShopSession _validateSession;

  Future<void> validate(String? token) async {
    emit(const ShopSessionState(status: ShopSessionStatus.loading));
    if (token == null || token.isEmpty) {
      emit(const ShopSessionState(status: ShopSessionStatus.invalid));
      return;
    }

    try {
      final isValid = await _validateSession(token: token);
      emit(
        ShopSessionState(
          status: isValid ? ShopSessionStatus.valid : ShopSessionStatus.invalid,
          shouldLogout: !isValid,
        ),
      );
    } catch (error) {
      emit(
        ShopSessionState(
          status: ShopSessionStatus.invalid,
          errorMessage: AppErrorMessage.from(error),
        ),
      );
    }
  }
}
