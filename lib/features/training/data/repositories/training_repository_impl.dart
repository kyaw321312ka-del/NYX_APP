import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/features/training/data/datasources/ClassApi/TrainingApi.dart';
import 'package:nyxproject/features/training/domain/entities/Training.dart';
import 'package:nyxproject/features/training/domain/repositories/training_repository.dart';

class TrainingRepositoryImpl implements TrainingRepository {
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
}
