import 'package:nyxproject/features/rental/domain/entities/Court.dart';

abstract class RentalRepository {
  Future<List<Court>> getCourts(int venueId);
}
