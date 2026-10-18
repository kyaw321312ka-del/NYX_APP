import 'package:nyxproject/features/dashboard/domain/entities/canteen.dart';
import 'package:nyxproject/features/rental/domain/entities/venue.dart';
import 'package:nyxproject/features/training/domain/entities/training.dart';

abstract class ServicesRepository {
  Future<List<Training>> getTrainings();
  Future<List<Venue>> getVenues();
  Future<List<Canteen>> getCanteenItems();
}
