import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/data/datasources/GetallproductApi.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/details.dart';

class TagPage extends StatefulWidget {
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
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  
  bool _isLoadingProducts = true;
  String? _productsError;
  
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
        _applyFilters();
      } else {
        setState(() {
          _productsError = result['message'] ?? 'Failed to load products';
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _productsError = 'Error loading products: $e';
        _isLoadingProducts = false;
      });
    }
  }

  void _clearSearch() {
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
    if (_allProducts.isEmpty) return;
    
    List<Product> results = List.from(_allProducts);

    // Filter by tag (if a specific tag is passed)
    if (widget.tagName != null && widget.tagName!.isNotEmpty && widget.tagName != "All") {
      results = results.where((product) {
        return product.tags != null && product.tags == widget.tagName;
      }).toList();
      print('Filtering by tag: ${widget.tagName}, found ${results.length} products');
    }
    
    // Filter by category (if a specific category is passed)
    else if (widget.categoryName != null && widget.categoryName!.isNotEmpty && widget.categoryName != "All") {
      results = results.where((product) {
        return product.category == widget.categoryName;
      }).toList();
      print('Filtering by category: ${widget.categoryName}, found ${results.length} products');
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      results = results.where((product) {
        return product.productName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
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

  @override
  Widget build(BuildContext context) {
    // Determine title based on what filter is applied
    String title;
    if (widget.tagName != null && widget.tagName!.isNotEmpty && widget.tagName != "All") {
      title = widget.tagName!;
    } else if (widget.categoryName != null && widget.categoryName!.isNotEmpty && widget.categoryName != "All") {
      title = widget.categoryName!;
    } else {
      title = "Products";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            _header(title),
            // _searchBar(),
            // _filterInfo(),
            Expanded(child: _gridCards())
          ],
        ),
      ),
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
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          SizedBox(
            child: IconButton(
              onPressed: (){}, 
              icon: const Icon(
                Icons.message, 
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  Widget _filterInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredProducts.length} products found',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Row(
            children: [
              const Text(
                'Sort: ',
                style: TextStyle(fontSize: 12),
              ),
              DropdownButton<String>(
                value: _selectedSort,
                items: const [
                  DropdownMenuItem(value: "None", child: Text("None")),
                  DropdownMenuItem(value: "low", child: Text("Price: Low to High")),
                  DropdownMenuItem(value: "high", child: Text("Price: High to Low")),
                  DropdownMenuItem(value: "az", child: Text("Name: A-Z")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value ?? "None";
                  });
                  _applyFilters();
                },
                underline: const SizedBox(),
              ),
            ],
          ),
        ],
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
      return Center(
        child: Column(
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
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
                                  value: loadingProgress.expectedTotalBytes != null
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
                          color: Colors.red,
                        ),
                      ),
                      if (product.tags != null && product.tags!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.tags!,
                            style: const TextStyle(fontSize: 8, color: Colors.orange),
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