import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/core/utils/app_constants.dart';
import 'package:nyxproject/features/user/data/models/contact_us.dart';

class ContactUsApi {
  static Future<Map<String, dynamic>> getGeneralInfo() async {
    try {
      return {'success': true, 'data': await ContactUsApi().fetchGeneralInfo()};
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    }
  }

  Future<ContactUsData> fetchGeneralInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.apiUrl}/contactus/showgeneral'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw ApiException('Server error: ${response.statusCode}');
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['status'] != 'success') {
        throw ApiException(
          responseData['message']?.toString() ?? 'Failed to fetch data',
        );
      }
      final dataList = responseData['data'];
      if (dataList is! List || dataList.isEmpty) {
        throw const ApiException('No data found');
      }
      if (dataList.first is! Map<String, dynamic>) {
        throw const ApiException('Invalid contact information received');
      }
      return ContactUsData.fromJson(dataList.first as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Connection error: $error');
    }
  }
}
