  import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/training/domain/entities/Training.dart';
import 'package:nyxproject/core/utils/app_constants.dart';

class TrainingApi {
  static Future<Map<String, dynamic>> getAllTrainings() async {
    final Uri uri = Uri.parse("${Constant.API_URL}/training/showtraining");

    try {
      final response = await http.get(
        uri,
        headers: Constant.headers,
      ).timeout(const Duration(seconds: 30));

      print("Training Response Status: ${response.statusCode}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> dataList = responseData['data'] ?? [];
        final List<Training> trainings = dataList
            .map((item) => Training.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': trainings,
          'message': 'Trainings fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch trainings',
        };
      }
    } catch (e) {
      print("Get Trainings Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}