import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/CourtApi.dart';
import 'package:nyxproject/features/rental/domain/entities/Court.dart';
import 'package:nyxproject/features/rental/domain/repositories/rental_repository.dart';

class RentalRepositoryImpl implements RentalRepository {
  @override
  Future<List<Court>> getCourts(int venueId) async {
    final result = await CourtApi.getCourtsByVenueId(venueId);
    if (result['success'] != true || result['data'] is! List<Court>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load courts',
      );
    }
    return result['data'] as List<Court>;
  }
}
