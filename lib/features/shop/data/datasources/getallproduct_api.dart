// lib/Util/getallproduct_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/core/utils/app_constants.dart';

class GetallproductApi {
  static Future<Map<String, dynamic>> getAllProducts() async {
    final Uri uri = Uri.parse("${Constant.apiUrl}/homecategory/showproduct");

    try {
      final http.Response response = await http
          .get(uri, headers: Constant.headers)
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response format from server: $e',
        };
      }

      // Check if responseData is a Map
      if (responseData is Map<String, dynamic>) {
        bool isSuccess = responseData['status'] == 'success';

        // Check if 'result' exists and is a List
        if (isSuccess &&
            responseData.containsKey('result') &&
            responseData['result'] is List) {
          final List productsList = responseData['result'];

          // Convert to List<Product>
          List<Product> products = productsList
              .map((item) => Product.fromJson(item))
              .toList();

          return {
            'success': true,
            'data': products,
            'message': 'Products fetched successfully',
          };
        } else {}

        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch products',
        };
      }

      return {
        'success': false,
        'message': 'Invalid response format - not a Map',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
