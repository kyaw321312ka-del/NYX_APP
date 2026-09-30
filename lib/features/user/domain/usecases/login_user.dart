import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';
import 'package:nyxproject/features/user/domain/repositories/user_repository.dart';

class LoginUser {
  const LoginUser(this._repository);

  final UserRepository _repository;

  Future<AuthenticatedUser> call({
    required String emailOrPhone,
    required String password,
  }) {
    return _repository.login(emailOrPhone: emailOrPhone, password: password);
  }
}
