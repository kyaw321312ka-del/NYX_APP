import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nyxproject/features/rental/domain/WalkinBookingList.dart';
import 'package:nyxproject/core/constants/app_constants.dart';

class WalkinBookingListApi {
  static Future<Map<String, dynamic>> getBookings({
    required String token,
  }) async {
    final uri = Uri.parse('${Constant.API_URL}/walk_in/booking_list');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final result = responseData['result'];

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          result is List) {
        return {
          'success': true,
          'data': result
              .whereType<Map<String, dynamic>>()
              .map(WalkinBookingList.fromJson)
              .toList(),
          'message': responseData['message'] ?? 'Bookings fetched successfully',
        };
      }

      return {
        'success': false,
        'message':
            responseData['message'] ??
            'Failed to fetch walk-in bookings (${response.statusCode})',
      };
    } catch (error) {
      return {'success': false, 'message': 'Network error: $error'};
    }
  }
}
