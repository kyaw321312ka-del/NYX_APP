import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/user/data/datasources/user_remote_data_source.dart';
import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(
    this._sessionService, {
    UserRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? UserRemoteDataSource();

  final SessionService _sessionService;
  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<AuthenticatedUser> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final authenticatedUser = await _remoteDataSource.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    await saveSession(authenticatedUser.user, authenticatedUser.token);
    return authenticatedUser;
  }

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
