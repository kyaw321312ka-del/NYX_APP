import 'package:nyxproject/features/rental/domain/entities/court.dart';
import 'package:nyxproject/features/rental/domain/repositories/rental_repository.dart';

class GetCourts {
  const GetCourts(this._repository);

  final RentalRepository _repository;

  Future<List<Court>> call(int venueId) => _repository.getCourts(venueId);
}
