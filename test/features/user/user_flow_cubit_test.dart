import 'package:flutter_test/flutter_test.dart';
import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/domain/entities/user_operations.dart';
import 'package:nyxproject/features/user/domain/repositories/user_repository.dart';
import 'package:nyxproject/features/user/presentation/bloc/user_flow_cubit.dart';

void main() {
  group('UserFlowCubit', () {
    test('emits a typed signup challenge from the repository', () async {
      final repository = _FakeUserRepository();
      final cubit = UserFlowCubit(repository);
      final emissions = <UserFlowState>[];
      final subscription = cubit.stream.listen(emissions.add);

      final result = await cubit.signup(
        name: 'Rin',
        email: 'rin@example.com',
        phone: '0912345678',
        dateOfBirth: '2000-01-01',
        password: 'secret1',
      );

      expect(result.tempToken, 'signup-token');
      expect(emissions.first.status, UserOperationStatus.loading);
      expect(cubit.state.status, UserOperationStatus.success);
      expect(cubit.state.operation, UserOperation.signup);
      expect(cubit.state.signupChallenge?.email, 'rin@example.com');
      await subscription.cancel();
      await cubit.close();
    });

    test('exposes repository failures as typed failure state', () async {
      final repository = _FakeUserRepository()..failPasswordReset = true;
      final cubit = UserFlowCubit(repository);

      await expectLater(
        cubit.requestPasswordReset(email: 'rin@example.com'),
        throwsA(isA<StateError>()),
      );
      expect(cubit.state.status, UserOperationStatus.failure);
      expect(cubit.state.operation, UserOperation.requestPasswordReset);
      expect(cubit.state.message, 'Reset unavailable');
      await cubit.close();
    });
  });
}

class _FakeUserRepository implements UserRepository {
  bool failPasswordReset = false;

  @override
  Future<AuthenticatedUser> login({
    required String emailOrPhone,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<void> saveSession(User user, String token) async {}

  @override
  Future<void> clearSession() async {}

  @override
  Future<SignupChallenge> signup({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
  }) async => SignupChallenge(email: email, tempToken: 'signup-token');

  @override
  Future<SignupAuthentication> verifySignup({
    required String email,
    required String tempToken,
    required String password,
    required String otp,
  }) async => const SignupAuthentication(verified: true);

  @override
  Future<PasswordChallenge> requestPasswordReset({
    required String email,
  }) async {
    if (failPasswordReset) throw StateError('Reset unavailable');
    return const PasswordChallenge(
      tempToken: 'reset-token',
      message: 'Code sent',
    );
  }

  @override
  Future<PasswordVerification> verifyPasswordReset({
    required String tempToken,
    required String otp,
  }) async => const PasswordVerification(resetToken: 'verified-token');

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String email,
  }) async {}

  @override
  Future<ProfileDetails> getProfile() async => ProfileDetails(user: User());

  @override
  Future<ProfileUpdate> updateProfile({
    required User user,
    String? imagePath,
  }) async => const ProfileUpdate();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<ContactInformation> getContactInformation() async =>
      const ContactInformation(shopName: 'NYX');
}
