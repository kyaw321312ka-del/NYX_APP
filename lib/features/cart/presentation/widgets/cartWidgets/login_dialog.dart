// lib/widgets/cartWidgets/login_dialog.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:provider/provider.dart';

class LoginDialog {
  static void show({
    required BuildContext context,
    required SessionService session,
  }) {
    final cartService = Provider.of<CartService>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to place your order.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await session.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      sessionService: session,
                      cartService: cartService,
                    ),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }
}