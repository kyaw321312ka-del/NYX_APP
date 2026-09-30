import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nyxproject/core/utils/app_constants.dart';

class WalkinBookinApi {
  static Future<Map<String, dynamic>> addWalkInBooking({
    required int venueId,
    required int courtId,
    required int walkInId,
    required String paymentMethod,
    required String date,
    required String name,
    required String phone,
    required String department,
    required List<Map<String, dynamic>> items,
    required File paymentImage,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('${Constant.API_URL}/walk_in/booking');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['vanue_id'] = venueId.toString()
        ..fields['court_id'] = courtId.toString()
        ..fields['walk_in_id'] = walkInId.toString()
        ..fields['payment_method'] = paymentMethod
        ..fields['date'] = date
        ..fields['name'] = name
        ..fields['phone'] = phone
        ..fields['items'] = jsonEncode(items)
        ..fields['department'] = department;

      request.files.add(
        await http.MultipartFile.fromPath('payment_image', paymentImage.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Booking successful',
        };
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to create booking',
      };
    } catch (error) {
      return {'success': false, 'message': 'Network error: $error'};
    }
  }
}
