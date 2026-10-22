import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/domain/entities/user_operations.dart';
import 'package:nyxproject/features/user/domain/repositories/user_repository.dart';

/// Application operations for user account and authentication workflows.
class UserUseCases {
  const UserUseCases(this._repository);

  final UserRepository _repository;

  Future<SignupChallenge> signup({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
  }) => _repository.signup(
    name: name,
    email: email,
    phone: phone,
    dateOfBirth: dateOfBirth,
    password: password,
  );

  Future<SignupAuthentication> verifySignup({
    required String email,
    required String tempToken,
    required String password,
    required String otp,
  }) => _repository.verifySignup(
    email: email,
    tempToken: tempToken,
    password: password,
    otp: otp,
  );

  Future<PasswordChallenge> requestPasswordReset({required String email}) =>
      _repository.requestPasswordReset(email: email);

  Future<PasswordVerification> verifyPasswordReset({
    required String tempToken,
    required String otp,
  }) => _repository.verifyPasswordReset(tempToken: tempToken, otp: otp);

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String email,
  }) => _repository.resetPassword(
    resetToken: resetToken,
    password: password,
    email: email,
  );

  Future<ProfileDetails> getProfile() => _repository.getProfile();

  Future<ProfileUpdate> updateProfile({
    required User user,
    String? imagePath,
  }) => _repository.updateProfile(user: user, imagePath: imagePath);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _repository.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  Future<void> deleteAccount() => _repository.deleteAccount();

  Future<ContactInformation> getContactInformation() =>
      _repository.getContactInformation();
}
