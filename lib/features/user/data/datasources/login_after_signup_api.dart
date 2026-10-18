import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/core/utils/app_constants.dart';

class LoginAfterSignupApi {
  static Future<Map<String, dynamic>> loginAfterSignup(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${Constant.apiUrl}/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrphone': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'token': data['token'] ?? data['access_token'],
          'user': data['user'] ?? data['data'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
