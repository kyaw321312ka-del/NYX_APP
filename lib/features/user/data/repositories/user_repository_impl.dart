import 'dart:io';

import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/user/data/models/user_model.dart';
import 'package:nyxproject/features/user/data/datasources/user_remote_data_source.dart';
import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/domain/entities/user_operations.dart';
import 'package:nyxproject/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    SessionService? sessionService,
    UserRemoteDataSource? remoteDataSource,
  }) : _sessionService = sessionService,
       _remoteDataSource = remoteDataSource ?? UserRemoteDataSource();

  final SessionService? _sessionService;
  final UserRemoteDataSource _remoteDataSource;

  SessionService get _session =>
      _sessionService ??
      (throw StateError('This operation requires a SessionService.'));

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
  Future<User?> getCurrentUser() async => _session.getStoredUser();

  @override
  Future<void> saveSession(User user, String token) {
    return _session.saveSession(user, token);
  }

  @override
  Future<void> clearSession() {
    return _session.clearSession();
  }

  @override
  Future<SignupChallenge> signup({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
  }) => _remoteDataSource.signup(
    name: name,
    email: email,
    phone: phone,
    dateOfBirth: dateOfBirth,
    password: password,
  );

  @override
  Future<SignupAuthentication> verifySignup({
    required String email,
    required String tempToken,
    required String password,
    required String otp,
  }) async {
    final result = await _remoteDataSource.verifySignup(
      email: email,
      tempToken: tempToken,
      password: password,
      otp: otp,
    );
    final authenticated = result.authenticatedUser;
    if (authenticated != null) {
      await saveSession(authenticated.user, authenticated.token);
    }
    return result;
  }

  @override
  Future<PasswordChallenge> requestPasswordReset({required String email}) =>
      _remoteDataSource.requestPasswordReset(email: email);

  @override
  Future<PasswordVerification> verifyPasswordReset({
    required String tempToken,
    required String otp,
  }) => _remoteDataSource.verifyPasswordReset(tempToken: tempToken, otp: otp);

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String email,
  }) => _remoteDataSource.resetPassword(
    resetToken: resetToken,
    password: password,
    email: email,
  );

  @override
  Future<ProfileDetails> getProfile() async {
    final token = _session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Session expired. Please login again.');
    }
    return _remoteDataSource.getProfile(token);
  }

  @override
  Future<ProfileUpdate> updateProfile({
    required User user,
    String? imagePath,
  }) async {
    final token = _session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Session expired. Please login again.');
    }
    final result = await _remoteDataSource.updateProfile(
      token: token,
      user: UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
        address: user.address,
      ),
      image: imagePath == null ? null : File(imagePath),
    );
    if (result.newToken != null && result.newToken!.isNotEmpty) {
      await _session.saveToken(result.newToken!);
    }
    return result;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = _session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Session expired. Please login again.');
    }
    await _remoteDataSource.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    await _session.clearSession();
  }

  @override
  Future<void> deleteAccount() async {
    final token = _session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('No authentication token found');
    }
    await _remoteDataSource.deleteAccount(token);
    await _session.clearSession();
  }

  @override
  Future<ContactInformation> getContactInformation() async {
    final contact = await _remoteDataSource.getContactInformation();
    return ContactInformation(
      logoImageUrl: contact.logoImageUrl,
      shopName: contact.shopName,
      contactInfo: contact.contactInfo,
      address: contact.address,
      socialLink: contact.socialLink,
    );
  }
}
