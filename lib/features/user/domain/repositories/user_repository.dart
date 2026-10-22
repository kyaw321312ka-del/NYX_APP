import 'package:nyxproject/features/user/domain/entities/user_operations.dart';
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

  Future<SignupChallenge> signup({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
  });

  Future<SignupAuthentication> verifySignup({
    required String email,
    required String tempToken,
    required String password,
    required String otp,
  });

  Future<PasswordChallenge> requestPasswordReset({required String email});

  Future<PasswordVerification> verifyPasswordReset({
    required String tempToken,
    required String otp,
  });

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String email,
  });

  Future<ProfileDetails> getProfile();

  Future<ProfileUpdate> updateProfile({required User user, String? imagePath});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount();

  Future<ContactInformation> getContactInformation();
}
