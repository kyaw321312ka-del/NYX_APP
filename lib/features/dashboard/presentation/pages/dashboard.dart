// lib/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/dashboard/data/datasources/HomeBannerApi.dart';
import 'package:nyxproject/features/shop/data/datasources/GetallproductApi.dart';
import 'package:nyxproject/features/shop/domain/entities/Category.dart';
import 'package:nyxproject/features/dashboard/domain/entities/HomeBanner.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/categoryPage.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/tagPage.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/banner_widget.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/categories_widget.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/product_section.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/section_header.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/core/network/api_client.dart';

class DashBoard extends StatefulWidget {
  final SessionService? sessionService;
  final CartService? cartService;

  const DashBoard({super.key, this.sessionService, this.cartService});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<Category> _categoriesList = [];
  List<Product> _allProducts = [];
  List<HomeBanner> _banners = [];

  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  bool _isLoadingBanners = true;
  bool _isRefreshing = false;

  String? _categoriesError;
  String? _productsError;
  String? _bannersError;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadAllData();

    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _loadAllData() async {
    await Future.wait([_loadBanners(), _loadCategories(), _loadProducts()]);
  }

  Future<void> _loadBanners() async {
    if (!mounted) return;

    setState(() {
      _isLoadingBanners = true;
      _bannersError = null;
    });

    try {
      final banners = await HomeBannerApi.getBanners();

      if (!mounted) return;
      setState(() {
        _banners = banners;
        _isLoadingBanners = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bannersError = AppErrorMessage.from(e);
        _isLoadingBanners = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;

    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final result = await Api.getAllCategories();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _categoriesList = result['data'] ?? [];
          _isLoadingCategories = false;
        });
        print(' Loaded ${_categoriesList.length} categories');
      } else {
        setState(() {
          _categoriesError = AppErrorMessage.from(
            result['message'] ?? 'Failed to load categories',
          );
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = AppErrorMessage.from(e);
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      final result = await GetallproductApi.getAllProducts();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _allProducts = result['data'] ?? [];
          _isLoadingProducts = false;
        });
        print(' Loaded ${_allProducts.length} products');
      } else {
        setState(() {
          _productsError = AppErrorMessage.from(
            result['message'] ?? 'Failed to load products',
          );
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _productsError = AppErrorMessage.from(e);
        _isLoadingProducts = false;
      });
    }
  }

  List<String> _getUniqueTags() {
    Set<String> tags = {};
    for (var product in _allProducts) {
      if (product.tags != null && product.tags!.isNotEmpty) {
        tags.add(product.tags!);
      }
    }
    return tags.toList();
  }

  List<Product> _getProductsByTag(String tagName) {
    return _allProducts.where((product) {
      return product.tags != null && product.tags == tagName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.red,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              if (_isLoadingBanners && !_isRefreshing)
                const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_bannersError != null)
                AppErrorView(
                  message: _bannersError!,
                  onRetry: _loadBanners,
                  compact: true,
                )
              else if (_banners.isNotEmpty)
                BannerWidget(
                  images: _banners.map((banner) => banner.imagePath).toList(),
                  onPageChanged: (index) {},
                ),
              const SizedBox(height: 3),
              // const Divider(thickness: 1, height: 2),
              SectionHeader(
                title: "Categories",
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(categoryName: "All"),
                    ),
                  );
                },
              ),
              CategoriesWidget(
                categories: _categoriesList,
                isLoading: _isLoadingCategories && !_isRefreshing,
                error: _categoriesError,
                onRetry: _loadCategories,
              ),
              // const Divider(thickness: 1, height: 1),
              _buildProductSections(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSections() {
    if (_isLoadingProducts && !_isRefreshing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_productsError != null) {
      return AppErrorView(
        message: _productsError!,
        onRetry: _loadProducts,
      );
    }

    if (_allProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No products available'),
        ),
      );
    }

    final uniqueTags = _getUniqueTags();

    if (uniqueTags.isEmpty) {
      return ProductSection(
        products: _allProducts,
        sectionTitle: "All Products",
        onSeeAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TagPage(tagName: "All Products"),
            ),
          );
        },
      );
    }

    return Column(
      children: uniqueTags.map((tagName) {
        final products = _getProductsByTag(tagName);
        if (products.isEmpty) return const SizedBox.shrink();
        return ProductSection(
          products: products,
          sectionTitle: tagName,
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TagPage(tagName: tagName),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
