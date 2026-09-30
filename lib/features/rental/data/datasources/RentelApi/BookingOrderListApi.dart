// lib/Util/RentelApi/BookingOrderListApi.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/rental/domain/entities/BookingOrderList.dart';
import 'package:nyxproject/core/utils/app_constants.dart';

class BookingOrderListApi {
  static Future<Map<String, dynamic>> getMobileBookings({
    required String token,
  }) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/rental/showmobilebooking");
    
    print("Booking List URL: $uri");
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("Booking List Response Status: ${response.statusCode}");
      print("Booking List Response Body: ${response.body}");

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
            'message': responseData['message'] ?? 'Bookings fetched successfully',
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
      print("Get Bookings Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}