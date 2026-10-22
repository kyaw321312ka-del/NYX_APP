import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/user/data/datasources/user_remote_data_source.dart';
import 'package:nyxproject/features/user/data/repositories/user_repository_impl.dart';
import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';
import 'package:nyxproject/features/user/domain/usecases/login_user.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  const LoginState({
    this.status = LoginStatus.initial,
    this.authenticatedUser,
    this.errorMessage,
  });

  final LoginStatus status;
  final AuthenticatedUser? authenticatedUser;
  final String? errorMessage;

  bool get isLoading => status == LoginStatus.loading;
}

class LoginController extends Cubit<LoginState> {
  LoginController(this._loginUser) : super(const LoginState());

  factory LoginController.forSession(SessionService sessionService) {
    final repository = UserRepositoryImpl(
      sessionService: sessionService,
      remoteDataSource: UserRemoteDataSource(),
    );
    return LoginController(LoginUser(repository));
  }

  final LoginUser _loginUser;

  Future<AuthenticatedUser?> login({
    required String emailOrPhone,
    required String password,
  }) async {
    emit(const LoginState(status: LoginStatus.loading));
    try {
      final user = await _loginUser(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      emit(LoginState(status: LoginStatus.success, authenticatedUser: user));
      return user;
    } catch (error) {
      final message = error.toString();
      emit(
        LoginState(
          status: LoginStatus.failure,
          errorMessage: message.startsWith('Exception: ')
              ? message.substring(11)
              : message,
        ),
      );
      return null;
    }
  }
}
