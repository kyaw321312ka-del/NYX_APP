import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_banners.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_dashboard_categories.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_dashboard_products.dart';
import 'package:nyxproject/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required GetBanners getBanners,
    required GetDashboardCategories getCategories,
    required GetDashboardProducts getProducts,
  }) : _getBanners = getBanners,
       _getCategories = getCategories,
       _getProducts = getProducts,
       super(const DashboardState());

  final GetBanners _getBanners;
  final GetDashboardCategories _getCategories;
  final GetDashboardProducts _getProducts;

  Future<void> loadAll() async {
    await Future.wait<void>([loadBanners(), loadCategories(), loadProducts()]);
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    emit(state.copyWith(isRefreshing: true));
    try {
      await loadAll();
    } finally {
      if (!isClosed) emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> loadBanners() async {
    emit(
      state.copyWith(
        isLoadingBanners: !state.isRefreshing,
        clearBannersError: true,
      ),
    );
    try {
      final banners = await _getBanners();
      if (isClosed) return;
      emit(
        state.copyWith(
          banners: banners,
          isLoadingBanners: false,
          clearBannersError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingBanners: false,
          bannersError: AppErrorMessage.from(error),
        ),
      );
    }
  }

  Future<void> loadCategories() async {
    emit(
      state.copyWith(
        isLoadingCategories: !state.isRefreshing,
        clearCategoriesError: true,
      ),
    );
    try {
      final categories = await _getCategories();
      if (isClosed) return;
      emit(
        state.copyWith(
          categories: categories,
          isLoadingCategories: false,
          clearCategoriesError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingCategories: false,
          categoriesError: AppErrorMessage.from(error),
        ),
      );
    }
  }

  Future<void> loadProducts() async {
    emit(
      state.copyWith(
        isLoadingProducts: !state.isRefreshing,
        clearProductsError: true,
      ),
    );
    try {
      final products = await _getProducts();
      if (isClosed) return;
      emit(
        state.copyWith(
          products: products,
          isLoadingProducts: false,
          clearProductsError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingProducts: false,
          productsError: AppErrorMessage.from(error),
        ),
      );
    }
  }
}
