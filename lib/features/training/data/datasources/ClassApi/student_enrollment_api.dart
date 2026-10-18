import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/training/domain/entities/student_enrollment.dart';
import 'package:nyxproject/core/utils/app_constants.dart';

class StudentEnrollmentApi {
  static Future<Map<String, dynamic>> getStudentEnrollments({
    required String token,
  }) async {
    final Uri uri = Uri.parse(
      "${Constant.apiUrl}/training/showstudenttraining",
    );

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          final List<dynamic> dataList = responseData['data'] ?? [];
          final List<StudentEnrollment> enrollments = dataList
              .map((item) => StudentEnrollment.fromJson(item))
              .toList();

          return {
            'success': true,
            'data': enrollments,
            'message':
                responseData['message'] ?? 'Enrollments fetched successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch enrollments',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
