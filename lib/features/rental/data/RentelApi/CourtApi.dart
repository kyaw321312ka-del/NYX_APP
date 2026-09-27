import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/rental/domain/Court.dart';
import 'package:nyxproject/core/constants/app_constants.dart';

class CourtApi {
  static Future<Map<String, dynamic>> getCourtsByVenueId(int venueId) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/rental/showcourt/$venueId");

    try {
      final http.Response response = await http.get(
        uri,
        headers: Constant.headers,
      ).timeout(const Duration(seconds: 30));

      print(" Court Response Status: ${response.statusCode}");
      print(" Court Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> dataList = responseData['data'] ?? [];
        final List<Court> courts = dataList
            .map((item) => Court.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': courts,
          'message': 'Courts fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch courts',
        };
      }
    } catch (e) {
      print(" Get Courts Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}