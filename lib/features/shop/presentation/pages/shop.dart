import 'package:flutter/material.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/shop/data/datasources/GetallproductApi.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/details.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';

class ShopPage extends StatefulWidget {
  final CartService? cartService;
  const ShopPage({super.key, this.cartService});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  bool _isLoading = true;
  String? _errorMessage;

  List<String> _brands = ["All"];
  String _selectedBrand = "All";
  String _searchQuery = "";
  String _selectedSort = "None";

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print("🔄 Loading products...");
      final result = await GetallproductApi.getAllProducts();

      if (!mounted) return; // ✅ Check before using setState

      print("📊 Result success: ${result['success']}");

      if (result['success'] == true) {
        final products = result['data'] as List<Product>;
        print("✅ Loaded ${products.length} products");

        setState(() {
          _allProducts = products;
          _filteredProducts = products;
          _isLoading = false;
        });

        _extractBrands();
        _applyFilters();
      } else {
        print("❌ API Error: ${result['message']}");
        setState(() {
          _errorMessage = AppErrorMessage.from(
            result['message'] ?? 'Failed to load products',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Exception: $e");
      if (!mounted) return; // ✅ Check before using setState
      setState(() {
        _errorMessage = AppErrorMessage.from(e);
        _isLoading = false;
      });
    }
  }

  void _extractBrands() {
    if (!mounted) return;

    Set<String> brandSet = {"All"};
    for (var product in _allProducts) {
      if (product.brand.isNotEmpty) {
        brandSet.add(product.brand);
      }
    }
    setState(() {
      _brands = brandSet.toList();
    });
    print("📋 Extracted brands: $_brands");
  }

  void _clearSearch() {
    if (!mounted) return;

    _controller.clear();
    setState(() {
      _searchQuery = "";
    });
    _applyFilters();
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
                setState(() {
                  _selectedSort = "low";
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Price: High to Low"),
              onTap: () {
                setState(() {
                  _selectedSort = "high";
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Name: A-Z"),
              onTap: () {
                setState(() {
                  _selectedSort = "az";
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _applyFilters() {
    if (!mounted) return;
    if (_allProducts.isEmpty) return;

    List<Product> results = List.from(_allProducts);

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      results = results.where((product) {
        return product.productName.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
      }).toList();
    }

    // Filter by selected brand
    if (_selectedBrand != "All") {
      results = results.where((product) {
        return product.brand == _selectedBrand;
      }).toList();
    }

    // Apply sorting
    if (_selectedSort == "low") {
      results.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == "high") {
      results.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSort == "az") {
      results.sort((a, b) => a.productName.compareTo(b.productName));
    }

    setState(() {
      _filteredProducts = results;
    });

    print("📊 Filtered products: ${_filteredProducts.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            _searchBar(),
            _filterBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text('Loading products...', style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return AppErrorView(
        message: _errorMessage!,
        onRetry: _loadProducts,
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
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

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.70,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
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
                    color: Colors.black.withOpacity(0.06),
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
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;

                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
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
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _applyFilters();
        },
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

  Widget _filterBar() {
    // Don't show filter bar while loading
    if (_isLoading) {
      return const SizedBox(
        height: 45,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_brands.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 45,
      margin: const EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _brands.length,
        itemBuilder: (context, index) {
          final brand = _brands[index];
          final isSelected = brand == _selectedBrand;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBrand = brand;
              });
              _applyFilters();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0D1B2A)
                    : Colors.grey.withOpacity(0.2),
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
