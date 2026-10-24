import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:nyxproject/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/banner_widget.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/categories_widget.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/product_section.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/section_header.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/category_page.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/tag_page.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: cubit.refresh,
            color: Colors.red,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildBanner(state, cubit),
                  const SizedBox(height: 3),
                  SectionHeader(
                    title: 'Categories',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryPage(categoryName: 'All'),
                        ),
                      );
                    },
                  ),
                  CategoriesWidget(
                    categories: state.categories,
                    isLoading: state.isLoadingCategories && !state.isRefreshing,
                    error: state.categoriesError,
                    onRetry: cubit.loadCategories,
                  ),
                  DashboardProductSections(state: state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(DashboardState state, DashboardCubit cubit) {
    if (state.isLoadingBanners && !state.isRefreshing) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.bannersError != null) {
      return AppErrorView(
        message: state.bannersError!,
        onRetry: cubit.loadBanners,
        compact: true,
      );
    }

    if (state.banners.isEmpty) return const SizedBox.shrink();

    return BannerWidget(
      images: state.banners.map((banner) => banner.imagePath).toList(),
      onPageChanged: (_) {},
    );
  }
}

class DashboardProductSections extends StatelessWidget {
  const DashboardProductSections({required this.state, super.key});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    if (state.isLoadingProducts && !state.isRefreshing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.productsError != null) {
      return AppErrorView(
        message: state.productsError!,
        onRetry: cubit.loadProducts,
      );
    }

    if (state.products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No products available'),
        ),
      );
    }

    final tags = state.products
        .map((product) => product.tags)
        .whereType<String>()
        .where((tag) => tag.isNotEmpty)
        .toSet();

    if (tags.isEmpty) {
      return _productSection(
        context,
        title: 'All Products',
        products: state.products,
        tagName: 'All Products',
        topSpacing: 2,
      );
    }

    return Column(
      children: tags.map((tag) {
        final products = state.products
            .where((product) => product.tags == tag)
            .toList();
        return _productSection(
          context,
          title: tag,
          products: products,
          tagName: tag,
          topSpacing: tag == tags.first ? 2 : 8,
        );
      }).toList(),
    );
  }

  Widget _productSection(
    BuildContext context, {
    required String title,
    required List<Product> products,
    required String tagName,
    required double topSpacing,
  }) {
    return ProductSection(
      products: products,
      sectionTitle: title,
      topSpacing: topSpacing,
      onSeeAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TagPage(tagName: tagName)),
        );
      },
    );
  }
}
