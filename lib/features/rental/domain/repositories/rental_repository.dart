import 'package:nyxproject/features/rental/domain/entities/court.dart';

abstract class RentalRepository {
  Future<List<Court>> getCourts(int venueId);
}
