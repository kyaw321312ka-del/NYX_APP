import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._sessionService);

  final SessionService _sessionService;

  @override
  Future<User?> getCurrentUser() async => _sessionService.getStoredUser();

  @override
  Future<void> saveSession(User user, String token) {
    return _sessionService.saveSession(user, token);
  }

  @override
  Future<void> clearSession() {
    return _sessionService.clearSession();
  }
}
