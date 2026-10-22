import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_categories.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_products.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_cubit.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_state.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/product_details.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';

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
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() =>
      context.read<ShopCatalogCubit>().loadProducts();

  void _clearSearch() {
    _controller.clear();
    context.read<ShopCatalogCubit>().setSearchQuery('');
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Price: Low to High"),
              onTap: () {
                context.read<ShopCatalogCubit>().selectSortOrder(
                  ShopSortOrder.priceAscending,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Price: High to Low"),
              onTap: () {
                context.read<ShopCatalogCubit>().selectSortOrder(
                  ShopSortOrder.priceDescending,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Name: A-Z"),
              onTap: () {
                context.read<ShopCatalogCubit>().selectSortOrder(
                  ShopSortOrder.nameAscending,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCatalogCubit, ShopCatalogState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                _searchBar(),
                _filterBar(state),
                Expanded(
                  child: RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: _loadProducts,
                    child: _buildContent(state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(ShopCatalogState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.status == ShopCatalogStatus.initial ||
        state.status == ShopCatalogStatus.loading) {
      return _scrollableState(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text('Loading products...', style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (state.status == ShopCatalogStatus.failure) {
      return _scrollableState(
        AppErrorView(message: state.errorMessage!, onRetry: _loadProducts),
      );
    }

    if (state.filteredProducts.isEmpty) {
      return _scrollableState(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text('No products found', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your filters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.70,
      ),
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        final hasDiscount = product.cost > product.price && product.cost > 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetails(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;

                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 50,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_outlined,
                              size: 50,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),

                /// INFO
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        product.brand,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// PRICE
                      Text(
                        "${product.price} Ks",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),

                      /// DISCOUNT
                      if (hasDiscount)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          // decoration: BoxDecoration(
                          //   color: colorScheme.error,
                          //   borderRadius: BorderRadius.circular(6),
                          // ),
                          child: Text(
                            "${(product.cost - product.price)} Ks",
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _scrollableState(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [SizedBox(height: 320, child: Center(child: child))],
    );
  }

  Widget _searchBar() {
    const navy = Color(0xFF0D1B2A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _controller,
        onChanged: context.read<ShopCatalogCubit>().setSearchQuery,
        style: const TextStyle(color: navy, fontSize: 14),
        cursorColor: navy,
        decoration: InputDecoration(
          hintText: "Search products...",
          hintStyle: const TextStyle(
            color: Color(0xFF89909C),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: navy, size: 23),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Filter or sort',
                icon: const Icon(Icons.tune_rounded, color: navy, size: 22),
                onPressed: _showSortBottomSheet,
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF737B89),
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                ),
            ],
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD8DDE5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD8DDE5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: navy, width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget _filterBar(ShopCatalogState state) {
    // Don't show filter bar while loading
    if (state.status == ShopCatalogStatus.loading ||
        state.status == ShopCatalogStatus.initial) {
      return const SizedBox(
        height: 45,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.brands.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 45,
      margin: const EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: state.brands.length,
        itemBuilder: (context, index) {
          final brand = state.brands[index];
          final isSelected = brand == state.selectedBrand;

          return GestureDetector(
            onTap: () => context.read<ShopCatalogCubit>().selectBrand(brand),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0D1B2A)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  brand,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
