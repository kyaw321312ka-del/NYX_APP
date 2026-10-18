import 'package:nyxproject/features/dashboard/domain/entities/Canteen.dart';
import 'package:nyxproject/features/rental/domain/entities/Venue.dart';
import 'package:nyxproject/features/training/domain/entities/Training.dart';

abstract class ServicesRepository {
  Future<List<Training>> getTrainings();
  Future<List<Venue>> getVenues();
  Future<List<Canteen>> getCanteenItems();
}
