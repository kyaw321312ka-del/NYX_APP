import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/features/dashboard/data/datasources/CanteenApi.dart';
import 'package:nyxproject/features/dashboard/domain/entities/Canteen.dart';
import 'package:nyxproject/features/dashboard/domain/repositories/services_repository.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/VenueApi.dart';
import 'package:nyxproject/features/rental/domain/entities/Venue.dart';
import 'package:nyxproject/features/training/data/datasources/ClassApi/TrainingApi.dart';
import 'package:nyxproject/features/training/domain/entities/Training.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  @override
  Future<List<Training>> getTrainings() async {
    final result = await TrainingApi.getAllTrainings();
    if (result['success'] != true || result['data'] is! List<Training>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load trainings',
      );
    }
    return result['data'] as List<Training>;
  }

  @override
  Future<List<Venue>> getVenues() async {
    final result = await VenueApi.getAllVenues();
    if (result['success'] != true || result['data'] is! List<Venue>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load venues',
      );
    }
    return result['data'] as List<Venue>;
  }

  @override
  Future<List<Canteen>> getCanteenItems() async {
    final result = await CanteenApi.getAllCanteenItems();
    if (result['success'] != true || result['data'] is! List<Canteen>) {
      throw ApiException(
        result['message']?.toString() ?? 'Failed to load canteen items',
      );
    }
    return result['data'] as List<Canteen>;
  }
}
