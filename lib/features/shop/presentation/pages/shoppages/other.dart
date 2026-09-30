import 'package:flutter/material.dart';

class dashboardPages extends StatefulWidget {
  const dashboardPages({super.key});

  @override
  State<dashboardPages> createState() => _dashboardPagesState();
}

class _dashboardPagesState extends State<dashboardPages> {
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
              // _searchBar(),
              // _filterBar(),
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
              "Other Pages",
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
                Icons.shopping_cart_rounded, 
                color: Colors.white,
              ),
            ),
          ),
        ],
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
      // itemCount: filteredProducts.length,
      itemCount: 8,
      itemBuilder: (context, index) {
        // final product = filteredProducts[index];

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
                    // product.name,
                    "Product Name",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  // product.catagories,
                  "Product Category",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  // "${product.price.toString()} Ks",
                  "35,000 Ks",
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