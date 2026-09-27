import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/core/constants/app_constants.dart';
import 'package:nyxproject/features/orders/domain/Payment.dart';

class PaymentApi {
  static Future<Map<String, dynamic>> getPaymentMethods({
    String? token,
  }) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/cart/showPayment");
    
    print("📡 Payment Methods URL: $uri");
    
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      final response = await http.get(uri, headers: headers);
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          final List<dynamic> paymentData = responseData['data'] ?? [];
          
          // Convert to List<PaymentMethod>
          final List<PaymentMethod> paymentMethods = paymentData
              .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
              .toList();
          
          return {
            'success': true,
            'data': paymentMethods,  // Returns List<PaymentMethod>
            'message': responseData['message'] ?? 'Payment methods fetched',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch payment methods',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Get Payment Methods Error: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}