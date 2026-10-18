import 'package:nyxproject/features/training/domain/entities/training.dart';

abstract class TrainingRepository {
  Future<List<Training>> getTrainings();
}
