import 'package:flutter/foundation.dart' show immutable;
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';

enum ShopCatalogStatus { initial, loading, success, failure }

enum ShopSortOrder { none, priceAscending, priceDescending, nameAscending }

@immutable
class ShopCatalogState {
  const ShopCatalogState({
    this.status = ShopCatalogStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.brands = const ['All'],
    this.searchQuery = '',
    this.selectedBrand = 'All',
    this.selectedCategory = 'All',
    this.sortOrder = ShopSortOrder.none,
    this.errorMessage,
    this.categoriesError,
    this.isLoadingCategories = false,
  });

  final ShopCatalogStatus status;
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<Category> categories;
  final List<String> brands;
  final String searchQuery;
  final String selectedBrand;
  final String selectedCategory;
  final ShopSortOrder sortOrder;
  final String? errorMessage;
  final String? categoriesError;
  final bool isLoadingCategories;

  ShopCatalogState copyWith({
    ShopCatalogStatus? status,
    List<Product>? products,
    List<Product>? filteredProducts,
    List<Category>? categories,
    List<String>? brands,
    String? searchQuery,
    String? selectedBrand,
    String? selectedCategory,
    ShopSortOrder? sortOrder,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? categoriesError,
    bool clearCategoriesError = false,
    bool? isLoadingCategories,
  }) {
    return ShopCatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      categoriesError: clearCategoriesError
          ? null
          : categoriesError ?? this.categoriesError,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
    );
  }
}
