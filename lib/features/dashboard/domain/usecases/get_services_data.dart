import 'package:nyxproject/features/dashboard/domain/entities/Canteen.dart';
import 'package:nyxproject/features/dashboard/domain/repositories/services_repository.dart';
import 'package:nyxproject/features/rental/domain/entities/Venue.dart';
import 'package:nyxproject/features/training/domain/entities/Training.dart';

class GetServicesData {
  const GetServicesData(this._repository);

  final ServicesRepository _repository;

  Future<List<Training>> getTrainings() => _repository.getTrainings();
  Future<List<Venue>> getVenues() => _repository.getVenues();
  Future<List<Canteen>> getCanteenItems() => _repository.getCanteenItems();
}
