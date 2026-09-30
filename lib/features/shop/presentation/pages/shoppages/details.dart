import 'package:flutter/material.dart';
import 'package:nyxproject/features/cart/presentation/pages/cart.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/shop/data/datasources/GetallproductApi.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  static const Color _navy = Color.fromARGB(255, 13, 27, 42);
  static const Color _accent = Color(0xFFE53935);
  static const Color _pageBg = Color(0xFFF5F6F8);

  int selectedIndex = 0;
  int _quantity = 1;
  bool _isAddingToCart = false;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  List<Product> _relatedProducts = [];
  bool _isLoadingRelated = true;

  int? get _availableStock => int.tryParse(widget.product.totalStock.trim());

  bool get _isInStock {
    final stock = _availableStock;
    if (stock != null) {
      return stock > 0;
    }
    return widget.product.status.toLowerCase() != "out of stock";
  }

  int get _quantityInCart {
    final cart = Provider.of<CartService>(context, listen: false);
    final itemIndex = cart.items.indexWhere(
      (item) => item.product.id == widget.product.id,
    );
    return itemIndex == -1 ? 0 : cart.items[itemIndex].quantity;
  }

  int get _remainingStock {
    final stock = _availableStock;
    return stock == null ? 0 : stock - _quantityInCart;
  }

  String get _stockStatusText {
    if (!_isInStock) {
      return "Out of Stock";
    }
    return "In Stock";
  }

  Color get _stockStatusColor {
    if (!_isInStock) {
      return _accent;
    }
    return const Color(0xFF4CAF50);
  }

  @override
  void initState() {
    super.initState();
    _loadRelatedProducts();
  }

  Future<void> _loadRelatedProducts() async {
    setState(() {
      _isLoadingRelated = true;
    });

    try {
      final result = await GetallproductApi.getAllProducts();

      if (result['success'] == true) {
        List<Product> allProducts = result['data'] ?? [];

        List<Product> related = allProducts.where((product) {
          return product.category == widget.product.category &&
              product.id != widget.product.id;
        }).toList();

        if (related.length > 4) {
          related = related.sublist(0, 4);
        }

        setState(() {
          _relatedProducts = related;
          _isLoadingRelated = false;
        });
      } else {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading related products: $e");
      setState(() {
        _isLoadingRelated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _header(cartService),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _imageSpace(),
                    const SizedBox(height: 12),
                    _priceTag(),
                    _name(),
                    const SizedBox(height: 10),
                    _color(),
                    const SizedBox(height: 10),
                    _size(),
                    const SizedBox(height: 6),
                    _quantitySelector(),
                    const SizedBox(height: 12),
                    _buildTabs(),
                    const SizedBox(height: 12),
                    selectedIndex == 0 ? _description() : _specification(),
                    const SizedBox(height: 8),
                    _section("Related Products"),
                    const SizedBox(height: 8),
                    _relatedProductsGrid(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _bottomBar(cartService),
          ],
        ),
      ),
    );
  }

  Widget _header(CartService cartService) {
    return Container(
      decoration: const BoxDecoration(color: _navy),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.08),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              "Product Details",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                ),
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              if (cartService.itemCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${cartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageSpace() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: widget.product.images.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  widget.product.images,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_outlined,
                        size: 90, color: Colors.grey.shade400);
                  },
                ),
              )
            : Icon(Icons.image_outlined, size: 90, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _priceTag() {
    bool hasDiscount = widget.product.cost > widget.product.price && widget.product.cost > 0;
    int? discountPercent;
    if (hasDiscount) {
      discountPercent = ((widget.product.cost - widget.product.price) /
              widget.product.cost *
              100)
          .round();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    "${widget.product.cost} Ks",
                    style: TextStyle(
                      fontFamily: "Custom",
                      color: Colors.white.withOpacity(0.5),
                      decoration: TextDecoration.lineThrough,
                      fontSize: 13,
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${widget.product.price} Ks",
                    style: const TextStyle(
                      fontFamily: "Custom",
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (discountPercent != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "-$discountPercent%",
                        style: const TextStyle(
                          fontFamily: "Custom",
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _stockStatusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _stockStatusText,
                    style: TextStyle(
                      fontFamily: "Custom",
                      color: _stockStatusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (_availableStock != null && _isInStock)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    "${_availableStock} available",
                    style: TextStyle(
                      fontFamily: "Custom",
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _name() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.product.productName,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          _circleAction(icon: Icons.favorite_border, onPressed: () {}),
          const SizedBox(width: 4),
          _circleAction(icon: Icons.share_outlined, onPressed: () {}),
        ],
      ),
    );
  }

  Widget _circleAction({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _optionSection({
    required String title,
    required List<String> options,
    required int selectedIndexValue,
    required ValueChanged<int> onSelect,
    required bool stadiumShape,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: "Custom",
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final bool isSelected = index == selectedIndexValue;
                return GestureDetector(
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: ShapeDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.06),
                      shape: stadiumShape
                          ? const StadiumBorder(
                              side: BorderSide(color: Colors.white24),
                            )
                          : RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white24,
                              ),
                            ),
                    ),
                    child: Text(
                      options[index],
                      style: TextStyle(
                        fontFamily: "Custom",
                        color: isSelected ? _navy : Colors.white,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _color() {
    List<String> colors = [];
    if (widget.product.colors.isNotEmpty) {
      colors = widget.product.colors.split(',').map((c) => c.trim()).toList();
    }

    if (colors.isEmpty) {
      colors = ["Default"];
    }

    if (_selectedColorIndex >= colors.length) {
      _selectedColorIndex = 0;
    }

    return _optionSection(
      title: "COLORS",
      options: colors,
      selectedIndexValue: _selectedColorIndex,
      onSelect: (index) {
        setState(() {
          _selectedColorIndex = index;
        });
      },
      stadiumShape: false,
    );
  }

  Widget _size() {
    List<String> sizes = [];
    if (widget.product.sizes.isNotEmpty) {
      sizes = widget.product.sizes.split(',').map((s) => s.trim()).toList();
    }

    if (sizes.isEmpty) {
      sizes = ["S", "M", "L", "XL"];
    }

    if (_selectedSizeIndex >= sizes.length) {
      _selectedSizeIndex = 0;
    }

    return _optionSection(
      title: "SIZES",
      options: sizes,
      selectedIndexValue: _selectedSizeIndex,
      onSelect: (index) {
        setState(() {
          _selectedSizeIndex = index;
        });
      },
      stadiumShape: true,
    );
  }

  Widget _quantitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Quantity",
            style: TextStyle(
              fontFamily: "Custom",
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _isInStock ? _pageBg : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isInStock && _quantity > 1
                      ? () {
                          setState(() {
                            _quantity--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Custom",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _isInStock ? _navy : Colors.grey,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isInStock && _quantity < _remainingStock
                      ? () {
                          setState(() {
                            _quantity++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabItem(title: "Description", index: 0),
          _tabItem(title: "Specification", index: 1),
        ],
      ),
    );
  }

  Widget _tabItem({required String title, required int index}) {
    final bool isActive = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _navy : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontFamily: "Custom",
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _description() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        widget.product.description.isNotEmpty
            ? widget.product.description
            : "No description available.",
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _specification() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _specRow("Brand", widget.product.brand),
          _specDivider(),
          _specRow("Category", widget.product.category),
          _specDivider(),
          _specRow("Made In", widget.product.made),
          _specDivider(),
          _specRow("Warranty", widget.product.warranty),
          _specDivider(),
          _specRow("Rating", widget.product.rating),
          _specDivider(),
          _specRow("Type", widget.product.types),
          _specDivider(),
          _specRow("Weight", widget.product.weights),
          if (widget.product.tags != null && widget.product.tags!.isNotEmpty) ...[
            _specDivider(),
            _specRow("Tags", widget.product.tags!),
          ],
        ],
      ),
    );
  }

  Widget _specDivider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "-",
              style: const TextStyle(
                fontFamily: "Custom",
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: _navy,
              fontWeight: FontWeight.w800,
              fontFamily: 'Custom',
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _relatedProductsGrid() {
    if (_isLoadingRelated) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: _navy),
        ),
      );
    }

    if (_relatedProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "No related products found",
            style: TextStyle(fontFamily: "Custom", fontSize: 14, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: _relatedProducts.length,
      itemBuilder: (context, index) {
        final product = _relatedProducts[index];
        return _relatedProductCard(product);
      },
    );
  }

  Widget _relatedProductCard(Product product) {
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  width: double.infinity,
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_outlined,
                                size: 60, color: Colors.grey.shade400);
                          },
                        )
                      : Icon(Icons.image_outlined,
                          size: 60, color: Colors.grey.shade400),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Custom',
                      fontWeight: FontWeight.w600,
                      color: _navy,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${product.price} Ks",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Custom',
                        fontSize: 13,
                        color: _accent,
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
  }

  Widget _bottomBar(CartService cartService) {
    bool hasDiscount = widget.product.cost > widget.product.price;
    int displayPrice = widget.product.price;
    int totalPrice = displayPrice * _quantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total Price",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "$totalPrice Ks",
                      style: const TextStyle(
                        fontFamily: "Custom",
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: _navy,
                      ),
                    ),
                    if (hasDiscount)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "${widget.product.cost * _quantity} Ks",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isInStock && _remainingStock > 0 && !_isAddingToCart
                ? () => _addToCart(cartService)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              disabledBackgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            icon: _isAddingToCart
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_shopping_cart, size: 18),
            label: Text(
              _isAddingToCart
                  ? "Adding..."
                  : _isInStock
                      ? "Add to Cart"
                      : "Out of Stock",
              style: const TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(CartService cartService) {
    if (!_isInStock || (_availableStock != null && _quantity > _remainingStock)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This quantity exceeds the available stock.'),
          backgroundColor: _accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    cartService.addToCart(widget.product, quantity: _quantity);

    ScaffoldMessenger.of(context).clearSnackBars();

    setState(() {
      _quantity = 1;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    });
  }
}
