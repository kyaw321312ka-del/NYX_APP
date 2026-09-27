// lib/widgets/cartWidgets/cart_summary.dart
import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final VoidCallback onAddMoreItems;
  final VoidCallback onOrderConfirm;
  final bool isCartEmpty;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.onAddMoreItems,
    required this.onOrderConfirm,
    this.isCartEmpty = false,
  });

  double get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal:", style: TextStyle(fontSize: 14)),
              Text("${subtotal.toStringAsFixed(0)} Ks", style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery Fee:", style: TextStyle(fontSize: 14)),
              Text("${deliveryFee.toStringAsFixed(0)} Ks", style: const TextStyle(fontSize: 14)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                "${total.toStringAsFixed(0)} Ks", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onAddMoreItems,
            child: const Text("Add more items", style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: isCartEmpty ? null : onOrderConfirm,
              child: const Text(
                "Order Confirm",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}