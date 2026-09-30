import 'package:flutter/foundation.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/user/data/datasources/user_remote_data_source.dart';
import 'package:nyxproject/features/user/data/repositories/user_repository_impl.dart';
import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';
import 'package:nyxproject/features/user/domain/usecases/login_user.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._loginUser);

  factory LoginController.forSession(SessionService sessionService) {
    final repository = UserRepositoryImpl(
      sessionService,
      remoteDataSource: UserRemoteDataSource(),
    );
    return LoginController(LoginUser(repository));
  }

  final LoginUser _loginUser;
  bool isLoading = false;
  String? errorMessage;

  Future<AuthenticatedUser?> login({
    required String emailOrPhone,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _loginUser(emailOrPhone: emailOrPhone, password: password);
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
