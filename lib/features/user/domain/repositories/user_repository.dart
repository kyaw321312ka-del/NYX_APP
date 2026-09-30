import 'package:nyxproject/features/user/domain/entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();

  Future<void> saveSession(User user, String token);

  Future<void> clearSession();
}
