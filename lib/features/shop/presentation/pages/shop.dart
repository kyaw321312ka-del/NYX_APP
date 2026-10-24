import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_categories.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_products.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_cubit.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_state.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/product_details.dart';
import 'package:nyxproject/features/shop/presentation/widgets/shop_brand_filter_bar.dart';
import 'package:nyxproject/features/shop/presentation/widgets/shop_catalog_content.dart';
import 'package:nyxproject/features/shop/presentation/widgets/shop_search_bar.dart';
import 'package:nyxproject/features/shop/presentation/widgets/shop_sort_options_sheet.dart';

class ShopPage extends StatelessWidget {
  final CartService? cartService;

  const ShopPage({super.key, this.cartService});

  @override
  Widget build(BuildContext context) {
    final repository = ShopRepositoryImpl();
    return BlocProvider(
      create: (_) => ShopCatalogCubit(
        getProducts: GetProducts(repository),
        getCategories: GetCategories(repository),
      )..load(),
      child: const _ShopPageContent(),
    );
  }
}

class _ShopPageContent extends StatefulWidget {
  const _ShopPageContent();

  @override
  State<_ShopPageContent> createState() => _ShopPageState();
}

class _ShopPageState extends State<_ShopPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() =>
      context.read<ShopCatalogCubit>().loadProducts();

  void _showSortOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => ShopSortOptionsSheet(
        onSelected: context.read<ShopCatalogCubit>().selectSortOrder,
      ),
    );
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetails(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCatalogCubit, ShopCatalogState>(
      builder: (context, state) {
        final isLoading =
            state.status == ShopCatalogStatus.initial ||
            state.status == ShopCatalogStatus.loading;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                ShopSearchBar(
                  controller: _searchController,
                  onQueryChanged: context
                      .read<ShopCatalogCubit>()
                      .setSearchQuery,
                  onSortTap: _showSortOptions,
                ),
                ShopBrandFilterBar(
                  brands: state.brands,
                  selectedBrand: state.selectedBrand,
                  isLoading: isLoading,
                  onBrandSelected: context.read<ShopCatalogCubit>().selectBrand,
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: _loadProducts,
                    child: ShopCatalogContent(
                      state: state,
                      onRetry: _loadProducts,
                      onProductSelected: _openProduct,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
