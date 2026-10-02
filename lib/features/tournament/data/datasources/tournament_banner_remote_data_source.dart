import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nyxproject/core/utils/app_constants.dart';
import 'package:nyxproject/features/tournament/data/models/tournament_banner_model.dart';

abstract class TournamentBannerRemoteDataSource {
  Future<List<TournamentBannerModel>> getBanners();
}

class TournamentBannerRemoteDataSourceImpl
    implements TournamentBannerRemoteDataSource {
  @override
  Future<List<TournamentBannerModel>> getBanners() async {
    final response = await http.get(
      Uri.parse('${Constant.API_URL}/tournament/banner'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load tournament banners: ${response.statusCode}',
      );
    }

    final decodedResponse = jsonDecode(response.body);
    if (decodedResponse is! Map<String, dynamic> ||
        decodedResponse['status'] != 'success') {
      throw Exception(
        decodedResponse is Map<String, dynamic>
            ? decodedResponse['message']?.toString() ??
                  'Failed to load tournament banners'
            : 'Invalid tournament banner response',
      );
    }

    final result = decodedResponse['result'];
    if (result is! List) {
      throw const FormatException('Invalid tournament banner response');
    }

    return result
        .whereType<Map<String, dynamic>>()
        .map(TournamentBannerModel.fromJson)
        .where((banner) => banner.imagePath.isNotEmpty)
        .toList();
  }
}
