import 'package:nyxproject/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';

class GetDashboardCategories {
  const GetDashboardCategories(this._repository);

  final DashboardRepository _repository;

  Future<List<Category>> call() => _repository.getCategories();
}
