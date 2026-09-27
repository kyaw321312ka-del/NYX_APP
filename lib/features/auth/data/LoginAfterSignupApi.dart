import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/core/constants/app_constants.dart';

class Loginaftersignupapi {
  static Future<Map<String, dynamic>> loginAfterSignup(
    String email,
    String password,
  ) async {
    try {
      print("📡 Calling login API with email: $email");
      
      final response = await http.post(
        Uri.parse("${Constant.API_URL}/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrphone': email, 'password': password}),
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'token': data['token'] ?? data['access_token'],
          'user': data['user'] ?? data['data'],
        };
      } else {
        return {
          'success': false, 
          'message': data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      print("❌ Login After Signup Error: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}