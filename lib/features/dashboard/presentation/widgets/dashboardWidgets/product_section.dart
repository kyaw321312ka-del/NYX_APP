import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/product_card.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/section_header.dart';

class ProductSection extends StatelessWidget {
  final List<Product> products;
  final String sectionTitle;
  final VoidCallback onSeeAll;
  final double topSpacing;

  const ProductSection({
    super.key,
    required this.products,
    required this.sectionTitle,
    required this.onSeeAll,
    this.topSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final displayProducts = products.take(4).toList();

    if (displayProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topSpacing),

        SectionHeader(title: sectionTitle, onSeeAll: onSeeAll),

        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.67,
          ),
          itemCount: displayProducts.length,
          itemBuilder: (context, index) {
            final product = displayProducts[index];

            return ProductCard(
              key: ValueKey(product.productName),
              product: product,
            );
          },
        ),

        const SizedBox(height: 8),

        Divider(
          color: Colors.grey.shade200,
          thickness: 1,
          height: 16,
          indent: 12,
          endIndent: 12,
        ),
      ],
    );
  }
}
