import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_categories.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_products.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_cubit.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_state.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/product_details.dart';

class TagPage extends StatelessWidget {
  final String? tagName;
  final String? categoryName;
  final int? categoryId;
  final int? index;

  const TagPage({
    super.key,
    this.tagName,
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
        tagFilter: tagName,
        initialCategory: tagName == null ? categoryName : null,
      )..load(),
      child: _TagPageContent(tagName: tagName, categoryName: categoryName),
    );
  }
}

class _TagPageContent extends StatefulWidget {
  final String? tagName;
  final String? categoryName;

  const _TagPageContent({this.tagName, this.categoryName});

  @override
  State<_TagPageContent> createState() => _TagPageState();
}

class _TagPageState extends State<_TagPageContent> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() =>
      context.read<ShopCatalogCubit>().loadProducts();

  @override
  Widget build(BuildContext context) {
    // Determine title based on what filter is applied
    String title;
    if (widget.tagName != null &&
        widget.tagName!.isNotEmpty &&
        widget.tagName != "All") {
      title = widget.tagName!;
    } else if (widget.categoryName != null &&
        widget.categoryName!.isNotEmpty &&
        widget.categoryName != "All") {
      title = widget.categoryName!;
    } else {
      title = "Products";
    }

    return BlocBuilder<ShopCatalogCubit, ShopCatalogState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFE0E0E0),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                _header(title),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadProducts,
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

  Widget _header(String title) {
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
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
          SizedBox(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.message, color: Colors.white),
            ),
          ),
        ],
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
      return _scrollableState(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
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
                          color: Colors.red,
                        ),
                      ),
                      if (product.tags != null && product.tags!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.tags!,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.orange,
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
}
