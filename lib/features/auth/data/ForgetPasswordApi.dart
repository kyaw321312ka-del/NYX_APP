import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nyxproject/core/constants/app_constants.dart';

class Forgetpasswordapi {
  // 1. Forget Password - Send OTP
  // Endpoint: ${Constant.API_URL}/auth/forgetpassword
  static Future<Map<String, dynamic>> forgetPassword({
    required String email,
  }) async {
    try {
      final url = Uri.parse('${Constant.API_URL}/auth/forgetpassword');
      print(" Sending OTP Request to: $url");
      print(" Email: $email");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print(" Response Status: ${response.statusCode}");
      print(" Response Body: ${response.body}");

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
    } catch (e) {
      print(" Error: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // 2. Verify OTP for Forget Password
  // Endpoint: ${Constant.API_URL}/auth/verifyforgetpassword
  static Future<Map<String, dynamic>> verifyForgetPassword({
    required String tempToken,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('${Constant.API_URL}/auth/verifyforgetpassword');
      print(" Verifying OTP at: $url");
      print(" TempToken: $tempToken");
      print(" OTP: $otp");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'tempToken': tempToken, 'otp': otp}),
      );

      print(" Response Status: ${response.statusCode}");
      print(" Response Body: ${response.body}");

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
    } catch (e) {
      print(" Error: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // 3. Update Password after verification
  // Endpoint: ${Constant.API_URL}/auth/verify_update_password
  static Future<Map<String, dynamic>> verifyUpdatePassword({
    required String tempToken,
    required String changePassword,
    required String email,
  }) async {
    try {
      final url = Uri.parse('${Constant.API_URL}/auth/verify_update_password');
      print(" Updating password at: $url");
      print(" ResetToken: $tempToken");
      print(" New Password: $changePassword");
      print(" Email: $email");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tempToken': tempToken,
          'change_password': changePassword,
          'email': email,
        }),
      );

      print(" Response Status: ${response.statusCode}");
      print(" Response Body: ${response.body}");

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
    } catch (e) {
      print(" Error: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
