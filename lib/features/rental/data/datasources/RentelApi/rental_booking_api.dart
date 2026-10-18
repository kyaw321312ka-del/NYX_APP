// lib/Util/RentelApi/rental_booking_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nyxproject/core/utils/app_constants.dart';

class RentalBookingApi {
  static Future<Map<String, dynamic>> addMobileRentalBooking({
    required int venueId,
    required int courtId,
    required int paymentId,
    required String date,
    required String name,
    required String phone,
    String? remark,
    required List<int> courtTimeSlotIds,
    required String department,
    required List<Map<String, dynamic>> items,
    required File? paymentImage,
    required String token,
  }) async {
    try {
      final Uri uri = Uri.parse(
        "${Constant.apiUrl}/rental/addmobilerentalbooking",
      );
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Format data as JSON strings
      String courtTimeSlotIdsJson = jsonEncode(courtTimeSlotIds);
      String itemsJson = items.isEmpty ? '[]' : jsonEncode(items);

      // Add form data fields
      request.fields['venue_id'] = venueId.toString();
      request.fields['court_id'] = courtId.toString();
      request.fields['payment_id'] = paymentId.toString();
      request.fields['date'] = date;
      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['remark'] = remark ?? '-';
      request.fields['court_time_slot_ids'] = courtTimeSlotIdsJson;
      request.fields['department'] = department;
      request.fields['items'] = itemsJson;

      // Debug prints

      // Add payment image if provided
      if (paymentImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('payment_image', paymentImage.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        // Try to extract error message from HTML
        String errorMsg = "Server error occurred";
        if (response.body.contains('<pre>')) {
          final start = response.body.indexOf('<pre>');
          final end = response.body.indexOf('</pre>');
          if (start != -1 && end != -1) {
            errorMsg = response.body.substring(start + 5, end);
          }
        }
        return {'success': false, 'message': errorMsg};
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Booking successful',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create booking',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
