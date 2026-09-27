import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nyxproject/features/rental/domain/WalkInCourt.dart';
import 'package:nyxproject/core/constants/app_constants.dart';

class WalkInCourtApi {
  static Future<Map<String, dynamic>> getWalkInCourts() async {
    final uri = Uri.parse('${Constant.API_URL}/walk_in/court_list');

    try {
      final response = await http
          .get(uri, headers: Constant.headers)
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> dataList;

      if (decoded is List) {
        dataList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is List) {
          dataList = data;
        } else if (decoded['result'] is List) {
          dataList = (decoded['result'] as List)
              .whereType<Map<String, dynamic>>()
              .expand((venue) {
                final venueName = venue['venue_name']?.toString() ?? '';
                final venueCourts = venue['courts'];
                if (venueCourts is! List) return <Map<String, dynamic>>[];

                return venueCourts.whereType<Map<String, dynamic>>().map((
                  court,
                ) {
                  final courtEquipment =
                      court['equipment'] ??
                      court['equipments'] ??
                      court['rental_equipment'] ??
                      court['rental_items'];
                  final venueEquipment =
                      venue['equipment'] ??
                      venue['equipments'] ??
                      venue['rental_equipment'] ??
                      venue['rental_items'];

                  return {
                    ...court,
                    'venue_id': venue['venue_id'],
                    'venue_name': venueName,
                    if (courtEquipment is! List && venueEquipment is List)
                      'equipment': venueEquipment,
                  };
                });
              })
              .toList();
        } else {
          dataList = [];
        }

        if (decoded['success'] == false) {
          return {
            'success': false,
            'message': decoded['message'] ?? 'Failed to fetch walk-in courts',
          };
        }
      } else {
        return {'success': false, 'message': 'Invalid response from server'};
      }

      return {
        'success': true,
        'data': dataList
            .whereType<Map<String, dynamic>>()
            .map(WalkInCourt.fromJson)
            .toList(),
      };
    } catch (error) {
      return {'success': false, 'message': 'Network error: $error'};
    }
  }
}
