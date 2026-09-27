// lib/pages/dashboardWidgets/product_section.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/domain/product.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/product_card.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/section_header.dart';

class ProductSection extends StatelessWidget {
  final List<Product> products;
  final String sectionTitle;
  final VoidCallback onSeeAll;

  const ProductSection({
    super.key,
    required this.products,
    required this.sectionTitle,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    // Show only first 4 products
    final displayProducts = products.length > 4 ? products.sublist(0, 4) : products;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SectionHeader(
          title: sectionTitle,
          onSeeAll: onSeeAll,
        ),
        // const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 5,
            childAspectRatio: 0.65,
          ),
          itemCount: displayProducts.length,
          itemBuilder: (context, index) {
            final product = displayProducts[index];
            return ProductCard(product: product);
          },
        ),
        const Divider(thickness: 1, height: 15),
      ],
    );
  }
}