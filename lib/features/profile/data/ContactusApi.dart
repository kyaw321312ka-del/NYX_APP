import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/profile/domain/Contactus.dart';

class ContactusApi {
  static const String baseUrl = 'http://130.94.99.9:5001/api';
  
  static Future<Map<String, dynamic>> getGeneralInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/contactus/showgeneral'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> dataList = responseData['data'];
          
          if (dataList.isNotEmpty) {
            final Map<String, dynamic> generalData = dataList[0];
            
            final contactData = ContactUsData(
              logoImageUrl: generalData['logo_image_url']?.toString(),
              shopName: generalData['shop_name']?.toString(),
              contactInfo: generalData['contact_info']?.toString(),
              address: generalData['address']?.toString(),
              socialLink: generalData['social_link']?.toString(),
            );
            
            return {
              'success': true,
              'data': contactData,
            };
          } else {
            return {
              'success': false,
              'message': 'No data found',
            };
          }
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch data',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}