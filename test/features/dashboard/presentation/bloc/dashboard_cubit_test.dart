import 'package:flutter_test/flutter_test.dart';
import 'package:nyxproject/features/dashboard/domain/entities/home_banner.dart';
import 'package:nyxproject/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_banners.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_dashboard_categories.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_dashboard_products.dart';
import 'package:nyxproject/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';

void main() {
  test(
    'loads dashboard content independently through the repository',
    () async {
      final cubit = DashboardCubit(
        getBanners: GetBanners(_FakeDashboardRepository()),
        getCategories: GetDashboardCategories(
          _FakeDashboardRepository(
            categoryError: Exception('Category failure'),
          ),
        ),
        getProducts: GetDashboardProducts(_FakeDashboardRepository()),
      );
      addTearDown(cubit.close);

      await cubit.loadAll();

      expect(cubit.state.banners, hasLength(1));
      expect(cubit.state.products, hasLength(1));
      expect(cubit.state.categories, isEmpty);
      expect(cubit.state.categoriesError, isNotNull);
      expect(cubit.state.isLoadingBanners, isFalse);
      expect(cubit.state.isLoadingCategories, isFalse);
      expect(cubit.state.isLoadingProducts, isFalse);
    },
  );
}

class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository({this.categoryError});

  final Object? categoryError;

  @override
  Future<List<HomeBanner>> getBanners() async => const [
    HomeBanner(id: 1, imagePath: 'banner.png'),
  ];

  @override
  Future<List<Category>> getCategories() async {
    if (categoryError != null) throw categoryError!;
    return [Category(id: 1, name: 'Category', imageUrl: '')];
  }

  @override
  Future<List<Product>> getProducts() async => [
    Product(
      id: 1,
      productName: 'Product',
      price: 10,
      cost: 10,
      description: '',
      warranty: '',
      rating: '',
      made: '',
      brand: '',
      category: '',
      images: '',
      publicIds: '',
      types: '',
      colors: '',
      sizes: '',
      weights: '',
      totalStock: '1',
      status: 'available',
    ),
  ];
}
