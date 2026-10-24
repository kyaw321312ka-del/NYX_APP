import 'package:flutter/material.dart';

class ShopBrandFilterBar extends StatelessWidget {
  const ShopBrandFilterBar({
    required this.brands,
    required this.selectedBrand,
    required this.isLoading,
    required this.onBrandSelected,
    super.key,
  });

  final List<String> brands;
  final String selectedBrand;
  final bool isLoading;
  final ValueChanged<String> onBrandSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 45,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (brands.length <= 1) {
      return const SizedBox.shrink();
    }

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
            onTap: () => onBrandSelected(brand),
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
