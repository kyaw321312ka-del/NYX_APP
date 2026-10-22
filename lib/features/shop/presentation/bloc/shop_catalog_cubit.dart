import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_categories.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_products.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_state.dart';

class ShopCatalogCubit extends Cubit<ShopCatalogState> {
  ShopCatalogCubit({
    required GetProducts getProducts,
    required GetCategories getCategories,
    this.tagFilter,
    String? initialCategory,
  }) : _getProducts = getProducts,
       _getCategories = getCategories,
       super(ShopCatalogState(selectedCategory: initialCategory ?? 'All'));

  final GetProducts _getProducts;
  final GetCategories _getCategories;
  final String? tagFilter;

  Future<void> load({bool includeCategories = false}) async {
    emit(
      state.copyWith(
        status: ShopCatalogStatus.loading,
        clearErrorMessage: true,
        isLoadingCategories: includeCategories,
        clearCategoriesError: true,
      ),
    );

    if (includeCategories) {
      await Future.wait<void>([loadProducts(), loadCategories()]);
    } else {
      await loadProducts();
    }
  }

  Future<void> loadProducts() async {
    emit(
      state.copyWith(
        status: ShopCatalogStatus.loading,
        clearErrorMessage: true,
      ),
    );
    try {
      final products = await _getProducts();
      final brands = <String>{
        'All',
        ...products
            .map((product) => product.brand)
            .where((brand) => brand.isNotEmpty),
      }.toList();
      emit(
        state.copyWith(
          status: ShopCatalogStatus.success,
          products: products,
          brands: brands,
          clearErrorMessage: true,
        ),
      );
      _applyFilters();
    } catch (error) {
      emit(
        state.copyWith(
          status: ShopCatalogStatus.failure,
          errorMessage: AppErrorMessage.from(error),
        ),
      );
    }
  }

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoadingCategories: true, clearCategoriesError: true));
    try {
      final categories = await _getCategories();
      emit(
        state.copyWith(
          categories: categories,
          isLoadingCategories: false,
          clearCategoriesError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingCategories: false,
          categoriesError: AppErrorMessage.from(error),
        ),
      );
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void selectBrand(String brand) {
    emit(state.copyWith(selectedBrand: brand));
    _applyFilters();
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
    _applyFilters();
  }

  void selectSortOrder(ShopSortOrder sortOrder) {
    emit(state.copyWith(sortOrder: sortOrder));
    _applyFilters();
  }

  void _applyFilters() {
    final query = state.searchQuery.trim().toLowerCase();
    var results = state.products.where((product) {
      if (query.isNotEmpty &&
          !product.productName.toLowerCase().contains(query)) {
        return false;
      }
      if (state.selectedBrand != 'All' &&
          product.brand != state.selectedBrand) {
        return false;
      }
      if (state.selectedCategory != 'All' &&
          product.category != state.selectedCategory) {
        return false;
      }
      if (tagFilter != null &&
          tagFilter!.isNotEmpty &&
          tagFilter != 'All' &&
          product.tags != tagFilter) {
        return false;
      }
      return true;
    }).toList();

    switch (state.sortOrder) {
      case ShopSortOrder.none:
        break;
      case ShopSortOrder.priceAscending:
        results.sort((a, b) => a.price.compareTo(b.price));
      case ShopSortOrder.priceDescending:
        results.sort((a, b) => b.price.compareTo(a.price));
      case ShopSortOrder.nameAscending:
        results.sort((a, b) => a.productName.compareTo(b.productName));
    }

    emit(state.copyWith(filteredProducts: results));
  }

  static List<Product> relatedProductsFor(Product product, List<Product> all) {
    return all
        .where(
          (candidate) =>
              candidate.category == product.category &&
              candidate.id != product.id,
        )
        .take(4)
        .toList();
  }
}
