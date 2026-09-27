import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nyxproject/features/dashboard/domain/HomeBanner.dart';

class HomeBannerApi {
  static const String _url = 'http://130.94.99.9:5001/api/banner';

  static Future<List<HomeBanner>> getBanners() async {
    final response = await http.get(Uri.parse(_url));

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
