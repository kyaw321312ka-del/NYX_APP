// lib/widgets/cartWidgets/cart_header.dart
import 'package:flutter/material.dart';

class CartHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const CartHeader({
    super.key,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          canPop || onBackPressed != null
            ? IconButton(
                onPressed: onBackPressed ?? () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              )
            : const SizedBox(width: 48),
          const Expanded(
            child: Text(
              "My Cart",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}