import 'package:flutter/foundation.dart' show immutable;
import 'package:nyxproject/features/dashboard/domain/entities/home_banner.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';

@immutable
class DashboardState {
  const DashboardState({
    this.banners = const [],
    this.categories = const [],
    this.products = const [],
    this.isLoadingBanners = true,
    this.isLoadingCategories = true,
    this.isLoadingProducts = true,
    this.isRefreshing = false,
    this.bannersError,
    this.categoriesError,
    this.productsError,
  });

  final List<HomeBanner> banners;
  final List<Category> categories;
  final List<Product> products;
  final bool isLoadingBanners;
  final bool isLoadingCategories;
  final bool isLoadingProducts;
  final bool isRefreshing;
  final String? bannersError;
  final String? categoriesError;
  final String? productsError;

  DashboardState copyWith({
    List<HomeBanner>? banners,
    List<Category>? categories,
    List<Product>? products,
    bool? isLoadingBanners,
    bool? isLoadingCategories,
    bool? isLoadingProducts,
    bool? isRefreshing,
    String? bannersError,
    bool clearBannersError = false,
    String? categoriesError,
    bool clearCategoriesError = false,
    String? productsError,
    bool clearProductsError = false,
  }) {
    return DashboardState(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      isLoadingBanners: isLoadingBanners ?? this.isLoadingBanners,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      bannersError: clearBannersError
          ? null
          : bannersError ?? this.bannersError,
      categoriesError: clearCategoriesError
          ? null
          : categoriesError ?? this.categoriesError,
      productsError: clearProductsError
          ? null
          : productsError ?? this.productsError,
    );
  }
}
