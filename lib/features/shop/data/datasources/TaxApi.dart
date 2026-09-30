import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/core/utils/app_constants.dart';
import 'package:nyxproject/features/shop/domain/entities/Tax.dart';

class TaxApi {
  static Future<Map<String, dynamic>> getTax() async {
    try {
      final Uri uri = Uri.parse("${Constant.API_URL}/cart/showTax");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> taxData = data['data'];
          if (taxData.isNotEmpty) {
            final tax = Tax.fromJson(taxData[0]);
            return {
              'success': true,
              'tax': tax,
            };
          }
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load tax',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load tax: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading tax: $e',
      };
    }
  }
}