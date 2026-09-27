import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/shop/domain/Category.dart';
import 'package:nyxproject/features/shop/domain/Tag.dart';
import 'package:nyxproject/core/constants/app_constants.dart';

class Api {
  // Login user - returns complete response data
  static Future<Map<String, dynamic>> loginUser({
    required String emailOrphone,
    required String password,
  }) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/auth/login");
    final String body = jsonEncode({
      "emailOrphone": emailOrphone.trim(),
      "password": password,
    });

    try {
      final http.Response response = await http.post(
        uri,
        headers: Constant.headers,
        body: body,
      );

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Server error: Invalid response format',
        };
      }

      // Get token
      final String token = responseData['token']?.toString() ?? '';

      // Check for invalid password response
      if (token == "Invalid password") {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      // Check for success
      bool isSuccess = false;
      if (responseData["success"] is bool && responseData["success"] == true) {
        isSuccess = true;
      } else if (responseData["status"] == "success" && token.isNotEmpty) {
        isSuccess = true;
      } else if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          token.isNotEmpty) {
        isSuccess = true;
      }

      return {
        'success': isSuccess,
        'data': responseData,
        'message':
            responseData['message'] ??
            (isSuccess ? 'Login successful' : 'Invalid credentials'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Signup user
  static Future<Map<String, dynamic>> signupUser({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
  }) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/auth/createUser");
    final String body = jsonEncode({
      "name": name,
      "email": email.trim(),
      "phone": phone,
      "dateOfBirth": dateOfBirth,
      "password": password,
    });

    try {
      print("Signup URL: $uri");
      print("Signup Body: $body");

      final http.Response response = await http
          .post(uri, headers: Constant.headers, body: body)
          .timeout(const Duration(seconds: 30));

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message':
              response.statusCode == 500 &&
                  response.body.contains("User already exist")
              ? "User already exists with this email or phone number"
              : 'Server error: Invalid response format',
        };
      }

      if (responseData is Map<String, dynamic>) {
        final bool isSuccess =
            (responseData['status'] == 'success') ||
            (responseData['success'] == true) ||
            (response.statusCode >= 200 && response.statusCode < 300);

        String tempToken = '';
        if (responseData['token'] != null &&
            responseData['token'] is Map<String, dynamic>) {
          tempToken = responseData['token']['tempToken']?.toString() ?? '';
        }

        return {
          'success': isSuccess,
          'data': responseData,
          'tempToken': tempToken,
          'message':
              responseData['token']?['message']?.toString() ??
              responseData['message']?.toString() ??
              (isSuccess ? 'Signup successful' : 'Signup failed'),
        };
      }

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': responseData,
        'message':
            'Signup ${response.statusCode >= 200 && response.statusCode < 300 ? "successful" : "failed"}',
      };
    } catch (e) {
      print("Signup Error: $e");
      return {'success': false, 'message': 'Network error, please try again.'};
    }
  }

  static Future<Map<String, dynamic>> sendOtpCode({
    required String email,
  }) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/auth/sendOtp");
    final String body = jsonEncode(<String, dynamic>{"email": email.trim()});

    try {
      final http.Response response = await http.post(
        uri,
        headers: Constant.headers,
        body: body,
      );

      if (response.body.isEmpty) {
        return <String, dynamic>{
          'success': response.statusCode >= 200 && response.statusCode < 300,
          'message': 'OTP sent',
        };
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return <String, dynamic>{
          'success': false,
          'message': 'Server error: Invalid response format',
        };
      }

      if (responseData is Map<String, dynamic>) {
        final dynamic rawSuccess = responseData['success'];
        final bool success = rawSuccess is bool
            ? rawSuccess
            : response.statusCode >= 200 && response.statusCode < 300;
        return <String, dynamic>{
          'success': success,
          'data': responseData,
          'message':
              responseData['message'] ??
              (success ? 'OTP sent' : 'Failed to send OTP'),
        };
      }

      return <String, dynamic>{
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': response.statusCode >= 200 && response.statusCode < 300
            ? 'OTP sent'
            : 'Failed to send OTP',
      };
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String tempToken,
  }) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/auth/verifyOtp");
    final String body = jsonEncode(<String, dynamic>{
      "otp": otp.trim(),
      "tempToken": tempToken.trim(),
    });

    try {
      final http.Response response = await http.post(
        uri,
        headers: Constant.headers,
        body: body,
      );

      if (response.body.isEmpty) {
        return <String, dynamic>{
          'success': false,
          'message': 'Empty response from server',
        };
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return <String, dynamic>{
          'success': false,
          'message': 'Server error: Invalid response format',
        };
      }

      if (responseData is Map<String, dynamic>) {
        final dynamic rawStatus = responseData['status'];
        final dynamic rawSuccess = responseData['success'];
        final bool success =
            (rawStatus is String && rawStatus.toLowerCase() == "success") ||
            (rawSuccess is bool && rawSuccess) ||
            response.statusCode >= 200 && response.statusCode < 300;
        return <String, dynamic>{
          'success': success,
          'data': responseData,
          'message':
              responseData['message'] ??
              (success ? 'Verification successful' : 'Invalid OTP'),
        };
      }

      return <String, dynamic>{
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': response.statusCode >= 200 && response.statusCode < 300
            ? 'Verification successful'
            : 'OTP verification failed',
      };
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error: $e'};
    }
  }

 static Future<Map<String, dynamic>> getMyProfile({
  required String token,
}) async {
  final Uri uri = Uri.parse("${Constant.API_URL}/myprofile/showprofile");

  try {
    final Map<String, String> authHeaders = {
      ...Constant.headers,
      'Authorization': 'Bearer $token',
    };

    final http.Response response = await http
        .get(uri, headers: authHeaders)
        .timeout(const Duration(seconds: 30));

    print("Profile Response Status: ${response.statusCode}");
    print("Profile Response Body: ${response.body}");

    // Check for 401 Unauthorized
    if (response.statusCode == 401) {
      return {
        'success': false,
        'unauthorized': true,
        'message': 'Session expired. Please login again.',
      };
    }

    // Check for 500 error with token expired message
    if (response.statusCode == 500 &&
        response.body.contains('TokenExpiredError')) {
      return {
        'success': false,
        'unauthorized': true,
        'message': 'Session expired. Please login again.',
      };
    }

    // Check if response is HTML instead of JSON
    if (response.body.trim().startsWith('<!DOCTYPE') ||
        response.body.trim().startsWith('<html')) {
      if (response.body.contains('TokenExpiredError')) {
        return {
          'success': false,
          'unauthorized': true,
          'message': 'Session expired. Please login again.',
        };
      }
      return {
        'success': false,
        'message': 'Server error: Invalid response format',
      };
    }

    if (response.body.isEmpty) {
      return {'success': false, 'message': 'Empty response from server'};
    }

    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      if (response.body.contains('TokenExpiredError')) {
        return {
          'success': false,
          'unauthorized': true,
          'message': 'Session expired. Please login again.',
        };
      }
      return {
        'success': false,
        'message': 'Invalid response format from server',
      };
    }

    if (responseData is Map<String, dynamic>) {
      bool isSuccess = responseData['status'] == 'success';

      if (isSuccess &&
          responseData['result'] != null &&
          responseData['result'] is List) {
        final List resultList = responseData['result'];
        if (resultList.isNotEmpty) {
          final userData = resultList[0];
          
          // Extract warning field from response
          final warning = userData['warning']?.toString() ?? 'false';

          return {
            'success': true,
            'data': userData,
            'warning': warning,  // Add warning to response
            'message': 'Profile fetched successfully',
          };
        } else {
          return {'success': false, 'message': 'No user data found'};
        }
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to fetch profile',
      };
    }

    return {'success': false, 'message': 'Invalid response format'};
  } catch (e) {
    print("Get Profile Error: $e");
    return {'success': false, 'message': 'Network error: $e'};
  }
}
  // Update profile
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/editProfiled/update");

    print("📡 Update URL: $uri");
    print("📦 Update Data: $userData");

    try {
      final http.Response response = await http
          .put(
            uri,
            headers: {...Constant.headers, 'Authorization': 'Bearer $token'},
            body: jsonEncode(userData),
          )
          .timeout(const Duration(seconds: 30));

      print("Update Response Status: ${response.statusCode}");
      print("Update Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'status': 'error', 'message': 'Empty response from server'};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);

          return {
            'status': 'success',
            'message': responseData['status'] ?? 'Profile updated',
            'new_token': responseData['result'],
            'data': responseData,
          };
        } catch (e) {
          return {
            'status': 'success',
            'message': 'Profile updated successfully',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'status': 'error',
          'unauthorized': true,
          'message': 'Session expired. Please login again.',
        };
      } else {
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['status'] ?? errorMessage;
        } catch (e) {}
        return {'status': 'error', 'message': errorMessage};
      }
    } catch (e) {
      print("Update Profile Error: $e");
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  // Upload profile image
  static Future<Map<String, dynamic>> uploadProfileImage({
    required String token,
    required File imageFile,
  }) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/editProfiled/uploadImage");

    print("📡 Upload URL: $uri");

    try {
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Upload Response Status: ${response.statusCode}");
      print("Upload Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String? newToken = responseData['result'];

        return {
          'status': 'success',
          'message': 'Image uploaded successfully',
          'new_token': newToken,
          'data': responseData,
        };
      } else if (response.statusCode == 401) {
        return {
          'status': 'error',
          'unauthorized': true,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {
          'status': 'error',
          'message': 'Failed to upload image: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Upload Image Error: $e");
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  static List<Category> categories = [];

  // Get all categories
  static Future<Map<String, dynamic>> getAllCategories() async {
    final Uri uri = Uri.parse("${Constant.API_URL}/homecategory/category");

    print("📡 Categories URL: $uri");

    try {
      final http.Response response = await http
          .get(uri, headers: Constant.headers)
          .timeout(const Duration(seconds: 30));

      print("Categories Response Status: ${response.statusCode}");
      print("Categories Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response format from server',
        };
      }

      if (responseData is Map<String, dynamic>) {
        bool isSuccess = responseData['status'] == 'success';

        if (isSuccess &&
            responseData['result'] != null &&
            responseData['result'] is List) {
          final List categoriesList = responseData['result'];

          List<Category> categories = categoriesList
              .map((category) => Category.fromJson(category))
              .toList();

          return {
            'success': true,
            'data': categories,
            'message': 'Categories fetched successfully',
          };
        }

        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch categories',
        };
      }

      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      print("Get Categories Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get home data with products grouped by tags
  static Future<Map<String, dynamic>> getHomeData() async {
    final Uri uri = Uri.parse("${Constant.API_URL}/homeshow/home");

    print("📡 Home Data URL: $uri");

    try {
      final http.Response response = await http
          .get(uri, headers: Constant.headers)
          .timeout(const Duration(seconds: 30));

      print("Home Data Response Status: ${response.statusCode}");
      print("Home Data Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response format from server',
        };
      }

      if (responseData is Map<String, dynamic>) {
        bool isSuccess = responseData['status'] == 'success';

        if (isSuccess &&
            responseData['result'] != null &&
            responseData['result'] is List) {
          final List resultList = responseData['result'];

          List<Map<String, dynamic>> groupedProducts = [];
          for (var group in resultList) {
            groupedProducts.add({
              'tagName': group['name'],
              'products': group['data'],
            });
          }

          return {
            'success': true,
            'data': groupedProducts,
            'message': 'Home data fetched successfully',
          };
        }

        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch home data',
        };
      }

      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      print("Get Home Data Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get all tags
  static Future<Map<String, dynamic>> getAllTags() async {
    final Uri uri = Uri.parse("${Constant.BASE_URL}/showtag/showtags");

    print("📡 Tags URL: $uri");

    try {
      final http.Response response = await http
          .get(uri, headers: Constant.headers)
          .timeout(const Duration(seconds: 30));

      print("Tags Response Status: ${response.statusCode}");
      print("Tags Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response format from server',
        };
      }

      if (responseData is Map<String, dynamic>) {
        bool isSuccess = responseData['status'] == 'success';

        if (isSuccess &&
            responseData['data'] != null &&
            responseData['data'] is List) {
          final List tagsList = responseData['data'];

          List<Tag> tags = tagsList.map((tag) => Tag.fromJson(tag)).toList();

          return {
            'success': true,
            'data': tags,
            'message': 'Tags fetched successfully',
          };
        }

        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch tags',
        };
      }

      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      print("Get Tags Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  
}
