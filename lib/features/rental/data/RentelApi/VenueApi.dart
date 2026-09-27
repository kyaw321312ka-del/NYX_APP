import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/rental/domain/Venue.dart';
import 'package:nyxproject/core/constants/app_constants.dart';

class VenueApi {
  static Future<Map<String, dynamic>> getAllVenues() async {
    final Uri uri = Uri.parse("${Constant.API_URL}/rental/showvenue");

    try {
      final http.Response response = await http.get(
        uri,
        headers: Constant.headers,
      ).timeout(const Duration(seconds: 30));

      print("📡 Venue Response Status: ${response.statusCode}");
      print("📡 Venue Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> dataList = responseData['data'] ?? [];
        final List<Venue> venues = dataList
            .map((item) => Venue.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': venues,
          'message': 'Venues fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch venues',
        };
      }
    } catch (e) {
      print("❌ Get Venues Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}