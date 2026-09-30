import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nyxproject/core/constants/app_constants.dart';
import 'package:nyxproject/features/dashboard/domain/HomeBanner.dart';

class HomeBannerApi {
  static Future<List<HomeBanner>> getBanners() async {
    final response = await http.get(Uri.parse('${Constant.API_URL}/banner'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load banners: ${response.statusCode}');
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseData['status'] != 'success') {
      throw Exception(responseData['message'] ?? 'Failed to load banners');
    }

    final result = responseData['result'];
    if (result is! List) {
      return [];
    }

    return result
        .whereType<Map<String, dynamic>>()
        .map(HomeBanner.fromJson)
        .where((banner) => banner.imagePath.isNotEmpty)
        .toList();
  }
}
