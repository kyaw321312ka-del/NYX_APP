import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/rental/domain/entities/AvaiSlotTime.dart';
import 'package:nyxproject/core/utils/app_constants.dart';

class AvailableSlotApi {
  static Future<Map<String, dynamic>> getAvailableSlots(
    int courtId,
    String date,
  ) async {
    final Uri uri = Uri.parse(
      "${Constant.API_URL}/rental/remainbookingslot/$courtId/$date",
    );

    try {
      final http.Response response = await http.get(
        uri,
        headers: Constant.headers,
      ).timeout(const Duration(seconds: 30));

      print("Available Slots Response Status: ${response.statusCode}");
      print("Available Slots Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> dataList = responseData['data'] ?? [];
        final List<AvailableSlot> slots = dataList
            .map((item) => AvailableSlot.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': slots,
          'message': 'Available slots fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch available slots',
        };
      }
    } catch (e) {
      print("Get Available Slots Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}