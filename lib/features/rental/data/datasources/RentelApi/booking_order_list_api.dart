// lib/Util/RentelApi/booking_order_list_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/rental/domain/entities/booking_order_list.dart';
import 'package:nyxproject/core/utils/app_constants.dart';

class BookingOrderListApi {
  static Future<Map<String, dynamic>> getMobileBookings({
    required String token,
  }) async {
    final Uri uri = Uri.parse("${Constant.apiUrl}/rental/showmobilebooking");

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
          final List<BookingOrder> bookings = dataList
              .map((item) => BookingOrder.fromJson(item))
              .toList();

          return {
            'success': true,
            'data': bookings,
            'message':
                responseData['message'] ?? 'Bookings fetched successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch bookings',
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
