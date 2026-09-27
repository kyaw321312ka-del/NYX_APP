// lib/widgets/cartWidgets/empty_cart.dart
import 'package:flutter/material.dart';

class EmptyCart extends StatelessWidget {
  final VoidCallback? onAddItems;

  const EmptyCart({
    super.key,
    this.onAddItems,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items to get started',
            style: TextStyle(color: Colors.grey),
          ),
          if (onAddItems != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAddItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Browse Products',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}