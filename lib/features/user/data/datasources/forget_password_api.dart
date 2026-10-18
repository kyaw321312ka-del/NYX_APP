import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nyxproject/core/utils/app_constants.dart';

class ForgetPasswordApi {
  // 1. Forget Password - Send OTP
  // Endpoint: ${Constant.apiUrl}/auth/forgetpassword
  static Future<Map<String, dynamic>> forgetPassword({
    required String email,
  }) async {
    try {
      final url = Uri.parse('${Constant.apiUrl}/auth/forgetpassword');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Extract tempToken from message object
          final messageData = data['message'] as Map<String, dynamic>;
          final String tempToken = messageData['tempToken']?.toString() ?? '';

          return {
            'success': true,
            'tempToken': tempToken,
            'message': messageData['message'] ?? 'OTP sent successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['message']?.toString() ?? 'Failed to send OTP',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } on Exception {
      return {
        'success': false,
        'message': 'Unable to connect. Check your internet connection.',
      };
    }
  }

  // 2. Verify OTP for Forget Password
  // Endpoint: ${Constant.apiUrl}/auth/verifyforgetpassword
  static Future<Map<String, dynamic>> verifyForgetPassword({
    required String tempToken,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('${Constant.apiUrl}/auth/verifyforgetpassword');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'tempToken': tempToken, 'otp': otp}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Extract the reset token for password update
          final String resetToken = data['token']?.toString() ?? '';

          return {
            'success': true,
            'resetToken': resetToken,
            'message': 'OTP verified successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['message']?.toString() ?? 'Invalid OTP',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } on Exception {
      return {
        'success': false,
        'message': 'Unable to verify the code. Please try again.',
      };
    }
  }

  // 3. Update Password after verification
  // Endpoint: ${Constant.apiUrl}/auth/verify_update_password
  static Future<Map<String, dynamic>> verifyUpdatePassword({
    required String tempToken,
    required String changePassword,
    required String email,
  }) async {
    try {
      final url = Uri.parse('${Constant.apiUrl}/auth/verify_update_password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tempToken': tempToken,
          'change_password': changePassword,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          return {
            'success': true,
            'result': data['result'] ?? true,
            'message': 'Password reset successfully',
          };
        } else {
          return {
            'success': false,
            'message':
                data['message']?.toString() ?? 'Failed to reset password',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } on Exception {
      return {
        'success': false,
        'message': 'Unable to update the password. Please try again.',
      };
    }
  }
}
