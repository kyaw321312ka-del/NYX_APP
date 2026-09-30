import 'package:nyxproject/features/training/domain/entities/Training.dart';

abstract class TrainingRepository {
  Future<List<Training>> getTrainings();
}
