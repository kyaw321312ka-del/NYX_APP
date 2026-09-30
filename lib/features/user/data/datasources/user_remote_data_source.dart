import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/core/network/api_client.dart';
import 'package:nyxproject/features/user/data/models/user_model.dart';
import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';

class UserRemoteDataSource {
  Future<AuthenticatedUser> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final loginResult = await Api.loginUser(
      emailOrphone: emailOrPhone,
      password: password,
    );

    if (loginResult['success'] != true) {
      throw ApiException(
        loginResult['message']?.toString() ?? 'Invalid email or password',
      );
    }

    final rawData = loginResult['data'];
    final response = rawData is Map<String, dynamic>
        ? rawData
        : <String, dynamic>{};
    final token = response['token']?.toString() ?? '';
    if (!_isValidToken(token)) {
      throw const ApiException('Invalid response from server.');
    }

    final profileResult = await Api.getMyProfile(token: token);
    final rawUser = profileResult['success'] == true
        ? profileResult['data']
        : response['user'] ?? response;
    if (rawUser is! Map<String, dynamic>) {
      throw const ApiException('Invalid user data received.');
    }

    final user = UserModel.fromJson({
      ...rawUser,
      'email': rawUser['email'] ?? emailOrPhone,
    });
    if (user.id == null || user.id == 0) {
      throw const ApiException('Invalid user data received.');
    }

    return AuthenticatedUser(user: user, token: token);
  }

  bool _isValidToken(String token) {
    return token.isNotEmpty &&
        token != 'Invalid password' &&
        token.split('.').length == 3;
  }
}
