import 'package:nyxproject/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';

class GetDashboardProducts {
  const GetDashboardProducts(this._repository);

  final DashboardRepository _repository;

  Future<List<Product>> call() => _repository.getProducts();
}
