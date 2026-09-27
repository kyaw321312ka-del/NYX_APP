import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/domain/Pp.dart';
// import 'package:nyxproject/features/shop/presentation/shoppages/details.dart';
// import 'package:nyxproject/features/shop/domain/product.dart';

class Catagory extends StatefulWidget {
  final int index;

  const Catagory({super.key, required this.index});

  @override
  State<Catagory> createState() => _CatagoryState();
}


class _CatagoryState extends State<Catagory> {

  final List<String> brands = [
    "All",
    "Badminton",
    "Football",
    "Golf",
    "Tennis",
    "Boxing",
    "Basketball"
  ];

  final List<Pp> allProducts = [
    Pp(name: "Shuttlecock", catagories: "Badminton", price: 45000, brand: '',),
    Pp(name: "Football", catagories: "Football", price: 35000, brand: ''),
    Pp(name: "Shoe", catagories: "Golf", price: 95000, brand: ''),
    Pp(name: "Hand Glove", catagories: "Golf", price: 65000, brand: ''),
    Pp(name: "Golf Bag", catagories: "Golf", price: 125000, brand: ''),
    Pp(name: "Shuttlecock", catagories: "Tennis", price: 55000, brand: ''),
    Pp(name: "Gloves", catagories: "Boxing", price: 34000, brand: ''),
    Pp(name: "Basketball", catagories: "Basketball", price: 50000, brand: ''),
  ];

  List<Pp> filteredProducts = [];

  String selectedBrand = "All";
  String searchQuery = "";

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProducts = allProducts ; // show all initially
  }

  void _clearSearch() {
    _controller.clear();
    searchQuery = "";
    _applyFilters();
  }

  String selectedSort = "None";

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
                  selectedSort = "low";
                });
                _applyFilters();
                Navigator.pop(context);
              }
            ),
            ListTile(
              title: const Text("Price: High to Low"),
              onTap: () {
                selectedSort = "high";
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Name: A-Z"),
              onTap: () {
                selectedSort = "az";
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
    List<Pp> results = allProducts;

    if (searchQuery.trim().isNotEmpty) {
      results = results.where((product) {
        return product.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (selectedBrand != "All") {
      results = results.where((product) {
        return product.catagories == selectedBrand; // ✅ correct
      }).toList();
    }

    if (selectedSort == "low") {
      results.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort == "high") {
      results.sort((a, b) => b.price.compareTo(a.price));
    } else if (selectedSort == "az") {
      results.sort((a, b) => a.name.compareTo(b.name));
    }

    setState(() {
      filteredProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5),
              _header(),
              const SizedBox(height: 5),
              _searchBar(),
              _filterBar(),
              _gridCards()
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            icon: Icon(
              Icons.arrow_back_ios_new_rounded, 
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              "Catagories",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          SizedBox(
            child: IconButton(
              onPressed: (){
              }, 
              icon: Icon(
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
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          searchQuery = value;
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
    return Container(
      height: 45,
      margin: const EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          final isSelected = brand == selectedBrand;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedBrand = brand;
              });
              _applyFilters();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(0xFF0D1B2A)
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

  Widget _gridCards() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];

        return GestureDetector(
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ProductDetails(product: product),
            //   ),
            // );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                const Expanded(
                  child: Icon(Icons.image, size: 160),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    product.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  product.catagories,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  "${product.price.toString()} Ks",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }
}