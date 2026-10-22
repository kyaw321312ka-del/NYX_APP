import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/user/data/repositories/user_repository_impl.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/domain/entities/user_operations.dart';
import 'package:nyxproject/features/user/domain/repositories/user_repository.dart';
import 'package:nyxproject/features/user/domain/usecases/user_use_cases.dart';

enum UserOperationStatus { initial, loading, success, failure }

enum UserOperation {
  signup,
  verifySignup,
  requestPasswordReset,
  verifyPasswordReset,
  resetPassword,
  loadProfile,
  updateProfile,
  changePassword,
  deleteAccount,
  loadContactInformation,
}

class UserFlowState {
  const UserFlowState({
    this.status = UserOperationStatus.initial,
    this.operation,
    this.message,
    this.signupChallenge,
    this.signupAuthentication,
    this.passwordChallenge,
    this.passwordVerification,
    this.profile,
    this.profileUpdate,
    this.contactInformation,
  });

  final UserOperationStatus status;
  final UserOperation? operation;
  final String? message;
  final SignupChallenge? signupChallenge;
  final SignupAuthentication? signupAuthentication;
  final PasswordChallenge? passwordChallenge;
  final PasswordVerification? passwordVerification;
  final ProfileDetails? profile;
  final ProfileUpdate? profileUpdate;
  final ContactInformation? contactInformation;

  bool get isLoading => status == UserOperationStatus.loading;
}

class UserFlowCubit extends Cubit<UserFlowState> {
  UserFlowCubit(UserRepository repository)
    : _useCases = UserUseCases(repository),
      super(const UserFlowState());

  factory UserFlowCubit.forSession(SessionService sessionService) =>
      UserFlowCubit(UserRepositoryImpl(sessionService: sessionService));

  factory UserFlowCubit.withoutSession({UserRepository? repository}) =>
      UserFlowCubit(repository ?? UserRepositoryImpl());

  final UserUseCases _useCases;

  Future<SignupChallenge> signup({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
  }) => _execute(
    UserOperation.signup,
    () => _useCases.signup(
      name: name,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      password: password,
    ),
    (value) => UserFlowState(
      status: UserOperationStatus.success,
      operation: UserOperation.signup,
      signupChallenge: value,
    ),
  );

  Future<SignupAuthentication> verifySignup({
    required String email,
    required String tempToken,
    required String password,
    required String otp,
  }) => _execute(
    UserOperation.verifySignup,
    () => _useCases.verifySignup(
      email: email,
      tempToken: tempToken,
      password: password,
      otp: otp,
    ),
    (value) => UserFlowState(
      status: UserOperationStatus.success,
      operation: UserOperation.verifySignup,
      signupAuthentication: value,
    ),
  );

  Future<PasswordChallenge> requestPasswordReset({required String email}) =>
      _execute(
        UserOperation.requestPasswordReset,
        () => _useCases.requestPasswordReset(email: email),
        (value) => UserFlowState(
          status: UserOperationStatus.success,
          operation: UserOperation.requestPasswordReset,
          passwordChallenge: value,
        ),
      );

  Future<PasswordVerification> verifyPasswordReset({
    required String tempToken,
    required String otp,
  }) => _execute(
    UserOperation.verifyPasswordReset,
    () => _useCases.verifyPasswordReset(tempToken: tempToken, otp: otp),
    (value) => UserFlowState(
      status: UserOperationStatus.success,
      operation: UserOperation.verifyPasswordReset,
      passwordVerification: value,
    ),
  );

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String email,
  }) => _execute<void>(
    UserOperation.resetPassword,
    () => _useCases.resetPassword(
      resetToken: resetToken,
      password: password,
      email: email,
    ),
    (_) => const UserFlowState(
      status: UserOperationStatus.success,
      operation: UserOperation.resetPassword,
    ),
  );

  Future<ProfileDetails> loadProfile() => _execute(
    UserOperation.loadProfile,
    _useCases.getProfile,
    (value) => UserFlowState(
      status: UserOperationStatus.success,
      operation: UserOperation.loadProfile,
      profile: value,
    ),
  );

  Future<ProfileUpdate> updateProfile({required User user, File? image}) =>
      _execute(
        UserOperation.updateProfile,
        () => _useCases.updateProfile(user: user, imagePath: image?.path),
        (value) => UserFlowState(
          status: UserOperationStatus.success,
          operation: UserOperation.updateProfile,
          profileUpdate: value,
        ),
      );

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _execute<void>(
    UserOperation.changePassword,
    () => _useCases.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ),
    (_) => const UserFlowState(
      status: UserOperationStatus.success,
      operation: UserOperation.changePassword,
    ),
  );

  Future<void> deleteAccount() => _execute<void>(
    UserOperation.deleteAccount,
    _useCases.deleteAccount,
    (_) => const UserFlowState(
      status: UserOperationStatus.success,
      operation: UserOperation.deleteAccount,
    ),
  );

  Future<ContactInformation> loadContactInformation() => _execute(
    UserOperation.loadContactInformation,
    _useCases.getContactInformation,
    (value) => UserFlowState(
      status: UserOperationStatus.success,
      operation: UserOperation.loadContactInformation,
      contactInformation: value,
    ),
  );

  Future<T> _execute<T>(
    UserOperation operation,
    Future<T> Function() action,
    UserFlowState Function(T value) onSuccess,
  ) async {
    emit(
      UserFlowState(status: UserOperationStatus.loading, operation: operation),
    );
    try {
      final value = await action();
      emit(onSuccess(value));
      return value;
    } catch (error) {
      emit(
        UserFlowState(
          status: UserOperationStatus.failure,
          operation: operation,
          message: _message(error),
        ),
      );
      rethrow;
    }
  }

  String _message(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) return text.substring(11);
    if (text.startsWith('Bad state: ')) return text.substring(11);
    return text;
  }
}
