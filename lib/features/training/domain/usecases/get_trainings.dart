import 'package:nyxproject/features/training/domain/entities/Training.dart';
import 'package:nyxproject/features/training/domain/repositories/training_repository.dart';

class GetTrainings {
  const GetTrainings(this._repository);

  final TrainingRepository _repository;

  Future<List<Training>> call() => _repository.getTrainings();
}
