import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_state.dart';

class ShopSortOptionsSheet extends StatelessWidget {
  const ShopSortOptionsSheet({required this.onSelected, super.key});

  final ValueChanged<ShopSortOrder> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Price: Low to High'),
          onTap: () => _select(context, ShopSortOrder.priceAscending),
        ),
        ListTile(
          title: const Text('Price: High to Low'),
          onTap: () => _select(context, ShopSortOrder.priceDescending),
        ),
        ListTile(
          title: const Text('Name: A-Z'),
          onTap: () => _select(context, ShopSortOrder.nameAscending),
        ),
      ],
    );
  }

  void _select(BuildContext context, ShopSortOrder sortOrder) {
    onSelected(sortOrder);
    Navigator.pop(context);
  }
}
