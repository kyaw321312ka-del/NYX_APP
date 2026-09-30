import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/data/datasources/GetallproductApi.dart';
import 'package:nyxproject/features/shop/domain/entities/Category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/details.dart';
import 'package:nyxproject/core/network/api_client.dart';

class CategoryPage extends StatefulWidget {
  final String? categoryName;
  final int? categoryId;
  final int? index;  // Make this optional

  const CategoryPage({
    super.key, 
    this.categoryName,
    this.categoryId,
    this.index,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  
  List<Category> _categoriesList = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  
  String? _categoriesError;
  String? _productsError;
  
  String _selectedCategory = "All";
  String _searchQuery = "";
  String _selectedSort = "None";
  
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // If categoryName is passed, set it as selected
    if (widget.categoryName != null) {
      _selectedCategory = widget.categoryName!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadProducts(),
    ]);
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final result = await Api.getAllCategories();

      if (result['success'] == true) {
        setState(() {
          _categoriesList = result['data'] ?? [];
          _isLoadingCategories = false;
        });
        print('✅ Loaded ${_categoriesList.length} categories');
      } else {
        setState(() {
          _categoriesError = result['message'] ?? 'Failed to load categories';
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        _categoriesError = 'Error loading categories: $e';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      final result = await GetallproductApi.getAllProducts();

      if (result['success'] == true) {
        setState(() {
          _allProducts = result['data'] ?? [];
          _isLoadingProducts = false;
        });
        print('✅ Loaded ${_allProducts.length} products');
        _applyFilters();
      } else {
        setState(() {
          _productsError = result['message'] ?? 'Failed to load products';
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        _productsError = 'Error loading products: $e';
        _isLoadingProducts = false;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    _searchQuery = "";
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
              }
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
    List<Product> results = List.from(_allProducts);

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      results = results.where((product) {
        return product.productName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by selected category
    if (_selectedCategory != "All") {
      results = results.where((product) {
        return product.category == _selectedCategory;
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
  }

  // Get category names for filter bar
  List<String> get _categoryNames {
    List<String> names = ["All"];
    names.addAll(_categoriesList.map((c) => c.name).toList());
    return names;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            _header(),
            const SizedBox(height: 5),
            _searchBar(),
            _filterBar(),
            Expanded(child: _gridCards())
          ],
        ),
      ),
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
                fontWeight: FontWeight.w600
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
        onChanged: (value) {
          _searchQuery = value;
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
    if (_isLoadingCategories) {
      return Container(
        height: 45,
        margin: const EdgeInsets.all(10),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_categoriesError != null) {
      return Container(
        height: 45,
        margin: const EdgeInsets.all(10),
        child: Center(
          child: Text(
            _categoriesError!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      height: 45,
      margin: const EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _categoryNames.length,
        itemBuilder: (context, index) {
          final category = _categoryNames[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
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

  Widget _gridCards() {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_productsError != null) {
      return Center(
        child: Text(
          _productsError!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];

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
                        ? Image.network(
                            product.images,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
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
}