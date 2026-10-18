// lib/Util/ClassApi/training_detail_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/training/domain/entities/training_detail.dart';
import 'package:nyxproject/core/utils/app_constants.dart';

class TrainingDetailApi {
  static Future<Map<String, dynamic>> getTrainingDetail(int trainingId) async {
    final Uri uri = Uri.parse(
      "${Constant.apiUrl}/training/showtraining/$trainingId",
    );

    try {
      final response = await http
          .get(uri, headers: Constant.headers)
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> dataList = responseData['data'] ?? [];
        if (dataList.isNotEmpty) {
          final trainingDetail = TrainingDetail.fromJson(dataList[0]);
          return {
            'success': true,
            'data': trainingDetail,
            'message': 'Training detail fetched successfully',
          };
        } else {
          return {'success': false, 'message': 'No training data found'};
        }
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to fetch training detail',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
