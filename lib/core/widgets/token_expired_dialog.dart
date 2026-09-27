import 'package:flutter/material.dart';
import 'package:nyxproject/features/auth/presentation/login.dart';
import 'package:nyxproject/core/storage/session_manager.dart';
import 'package:nyxproject/features/cart/domain/cart_service.dart';

class TokenExpiredDialog {
  static void show(BuildContext context, {required SessionService sessionService, required CartService cartService}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Session Expired'),
            ],
          ),
          content: const Text(
            'Your session has expired. Please login again to continue.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear session
                await sessionService.logout();
                
                // Navigate to login page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      sessionService: sessionService,
                      cartService: cartService,
                    ),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Login Now'),
            ),
          ],
        );
      },
    );
  }
}