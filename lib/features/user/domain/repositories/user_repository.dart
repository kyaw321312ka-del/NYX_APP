import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';

abstract class UserRepository {
  Future<AuthenticatedUser> login({
    required String emailOrPhone,
    required String password,
  });

  Future<User?> getCurrentUser();

  Future<void> saveSession(User user, String token);

  Future<void> clearSession();
}
  