import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/core/network/api_client.dart';
import 'package:nyxproject/core/utils/app_constants.dart';
import 'package:nyxproject/features/user/data/datasources/contact_us_api.dart';
import 'package:nyxproject/features/user/data/datasources/forget_password_api.dart';
import 'package:nyxproject/features/user/data/datasources/login_after_signup_api.dart';
import 'package:nyxproject/features/user/data/models/contact_us.dart';
import 'package:nyxproject/features/user/data/models/user_model.dart';
import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';
import 'package:nyxproject/features/user/domain/entities/user_operations.dart';

class UserRemoteDataSource {
  UserRemoteDataSource({ContactUsApi? contactUsApi})
    : _contactUsApi = contactUsApi ?? ContactUsApi();

  final ContactUsApi _contactUsApi;

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

  Future<SignupChallenge> signup({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
  }) async {
    final result = await Api.signupUser(
      name: name,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      password: password,
    );
    if (result['success'] != true) {
      throw ApiException(result['message']?.toString() ?? 'Signup failed');
    }
    final token = result['tempToken']?.toString() ?? '';
    if (token.isEmpty) {
      throw const ApiException('Missing verification token from server');
    }
    return SignupChallenge(email: email, tempToken: token);
  }

  Future<SignupAuthentication> verifySignup({
    required String email,
    required String tempToken,
    required String password,
    required String otp,
  }) async {
    final verifyResult = await Api.verifyOtp(otp: otp, tempToken: tempToken);
    if (verifyResult['success'] != true) {
      throw ApiException(verifyResult['message']?.toString() ?? 'Invalid OTP');
    }

    final loginResult = await LoginAfterSignupApi.loginAfterSignup(
      email,
      password,
    );
    if (loginResult['success'] != true) {
      return const SignupAuthentication(verified: true);
    }

    final token = loginResult['token']?.toString() ?? '';
    if (token.isEmpty) {
      return const SignupAuthentication(verified: true);
    }
    var user = UserModel(name: email.split('@').first, email: email, phone: '');

    try {
      final profileResult = await Api.getMyProfile(token: token);
      if (profileResult['success'] == true &&
          profileResult['data'] is Map<String, dynamic>) {
        user = UserModel.fromJson({
          ...profileResult['data'] as Map<String, dynamic>,
          'email': email,
        });
      }
    } on Exception {
      // Signing up is successful even if optional profile enrichment fails.
    }
    return SignupAuthentication(
      verified: true,
      authenticatedUser: AuthenticatedUser(user: user, token: token),
    );
  }

  Future<PasswordChallenge> requestPasswordReset({
    required String email,
  }) async {
    final result = await ForgetPasswordApi.forgetPassword(email: email);
    if (result['success'] != true) {
      throw ApiException(result['message']?.toString() ?? 'Failed to send OTP');
    }
    return PasswordChallenge(
      tempToken: result['tempToken']?.toString() ?? '',
      message: result['message']?.toString() ?? 'OTP sent successfully',
    );
  }

  Future<PasswordVerification> verifyPasswordReset({
    required String tempToken,
    required String otp,
  }) async {
    final result = await ForgetPasswordApi.verifyForgetPassword(
      tempToken: tempToken,
      otp: otp,
    );
    if (result['success'] != true) {
      throw ApiException(result['message']?.toString() ?? 'Invalid OTP');
    }
    return PasswordVerification(
      resetToken: result['resetToken']?.toString() ?? '',
    );
  }

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String email,
  }) async {
    final result = await ForgetPasswordApi.verifyUpdatePassword(
      tempToken: resetToken,
      changePassword: password,
      email: email,
    );
    if (result['success'] != true) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to reset password',
      );
    }
  }

  Future<ProfileDetails> getProfile(String token) async {
    final result = await Api.getMyProfile(token: token);
    if (result['unauthorized'] == true) {
      throw const ApiException(
        'Session expired. Please login again.',
        statusCode: 401,
      );
    }
    if (result['success'] != true || result['data'] is! Map<String, dynamic>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to fetch profile',
      );
    }
    return ProfileDetails(
      user: UserModel.fromJson(result['data'] as Map<String, dynamic>),
      warning: result['warning']?.toString(),
    );
  }

  Future<ProfileUpdate> updateProfile({
    required String token,
    required UserModel user,
    File? image,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${Constant.apiUrl}/editProfiled/update'),
    );
    request.headers.addAll({
      'Authorization': '******',
      'Accept': 'application/json',
    });
    request.fields.addAll({
      'name': user.name ?? '',
      'email': user.email ?? '',
      'phone': user.phone ?? '',
      'dateOfbirth': user.dateOfBirth ?? '',
      'address': user.address ?? '',
    });
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 401) {
      throw const ApiException(
        'Session expired. Please login again.',
        statusCode: 401,
      );
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw const ApiException('Update failed');
    }
    if (response.body.isEmpty) return const ProfileUpdate();
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'success' && data['status'] != 'Edit Profile') {
      throw ApiException(data['status']?.toString() ?? 'Update failed');
    }
    return ProfileUpdate(newToken: data['result']?.toString());
  }

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${Constant.apiUrl}/changepassword/password'),
      headers: {'Content-Type': 'application/json', 'Authorization': '******'},
      body: jsonEncode({
        'password': currentPassword,
        'changePassword': newPassword,
      }),
    );
    if (response.statusCode == 401) {
      throw const ApiException(
        'Session expired. Please login again.',
        statusCode: 401,
      );
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        data['status']?.toString() ?? 'Failed to change password',
      );
    }
    if (response.statusCode == 201 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == false ||
          data['status'] == 'error' ||
          data['result'] == false) {
        throw ApiException(
          data['message']?.toString() ?? 'Failed to change password',
        );
      }
    }
  }

  Future<void> deleteAccount(String token) async {
    final response = await http.put(
      Uri.parse('${Constant.apiUrl}/auth/delete_acc'),
      headers: {'Authorization': '******', 'Content-Type': 'application/json'},
    );
    final data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['status'] == 'success' &&
        data['result'] == true) {
      return;
    }
    throw ApiException(
      data['message']?.toString() ?? 'Failed to delete account',
      statusCode: response.statusCode,
    );
  }

  Future<ContactUsData> getContactInformation() async {
    return _contactUsApi.fetchGeneralInfo();
  }

  bool _isValidToken(String token) {
    return token.isNotEmpty &&
        token != 'Invalid password' &&
        token.split('.').length == 3;
  }
}
