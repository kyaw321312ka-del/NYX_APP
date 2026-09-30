import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/dashboard/domain/entities/Canteen.dart';
import 'package:nyxproject/core/utils/app_constants.dart';

class CanteenApi {
  static Future<Map<String, dynamic>> getAllCanteenItems() async {
    final Uri uri = Uri.parse("${Constant.API_URL}/canteen/showmenu");

    try {
      final http.Response response = await http.get(
        uri,
        headers: Constant.headers,
      ).timeout(const Duration(seconds: 30));

      print("📡 Canteen Response Status: ${response.statusCode}");
      print("📡 Canteen Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        final List<dynamic> resultList = responseData['result'] ?? [];
        final List<Canteen> canteenItems = resultList
            .map((item) => Canteen.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': canteenItems,
          'message': 'Canteen items fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch canteen items',
        };
      }
    } catch (e) {
      print("❌ Get Canteen Items Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}