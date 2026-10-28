import 'package:flutter/material.dart';
import 'package:nyxproject/core/presentation/widgets/cors_safe_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_categories.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_products.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_cubit.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_state.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/product_details.dart';

class CategoryPage extends StatelessWidget {
  final String? categoryName;
  final int? categoryId;
  final int? index;

  const CategoryPage({
    super.key,
    this.categoryName,
    this.categoryId,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final repository = ShopRepositoryImpl();
    return BlocProvider(
      create: (_) => ShopCatalogCubit(
        getProducts: GetProducts(repository),
        getCategories: GetCategories(repository),
        initialCategory: categoryName,
      )..load(includeCategories: true),
      child: _CategoryPageContent(categoryName: categoryName),
    );
  }
}

class _CategoryPageContent extends StatefulWidget {
  final String? categoryName;

  const _CategoryPageContent({this.categoryName});

  @override
  State<_CategoryPageContent> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<_CategoryPageContent> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() =>
      context.read<ShopCatalogCubit>().load(includeCategories: true);

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
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                _header(),
                const SizedBox(height: 5),
                _searchBar(),
                _filterBar(state),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF0D1B2A),
                    child: _gridCards(state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header() {
    // Use the category name if provided, otherwise use "Categories"
    final title = widget.categoryName ?? "Categories";

    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // SizedBox(
          //   child: IconButton(
          //     onPressed: (){},
          //     icon: const Icon(
          //       Icons.message,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: _controller,
        onChanged: context.read<ShopCatalogCubit>().setSearchQuery,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: "What are you looking for?",
          filled: true,
          fillColor: const Color(0xFF0D1B2A),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: _showSortBottomSheet,
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: _clearSearch,
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _filterBar(ShopCatalogState state) {
    if (state.isLoadingCategories) {
      return Container(
        height: 45,
        margin: const EdgeInsets.all(10),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.categoriesError != null) {
      return Container(
        height: 45,
        margin: const EdgeInsets.all(10),
        child: Center(
          child: Text(
            state.categoriesError!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    }

    final categoryNames = [
      'All',
      ...state.categories.map((category) => category.name),
    ];

    return Container(
      height: 45,
      margin: const EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categoryNames.length,
        itemBuilder: (context, index) {
          final category = categoryNames[index];
          final isSelected = category == state.selectedCategory;

          return GestureDetector(
            onTap: () =>
                context.read<ShopCatalogCubit>().selectCategory(category),
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
                  category,
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

  Widget _gridCards(ShopCatalogState state) {
    if (state.status == ShopCatalogStatus.initial ||
        state.status == ShopCatalogStatus.loading) {
      return _scrollableState(const CircularProgressIndicator());
    }

    if (state.status == ShopCatalogStatus.failure) {
      return _scrollableState(
        Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (state.filteredProducts.isEmpty) {
      return _scrollableState(const Text('No products found'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetails(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(11),
                    ),
                    child: product.images.isNotEmpty
                        ? CorsSafeNetworkImage.network(
                            product.images,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${product.price.toString()} Ks",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
}
