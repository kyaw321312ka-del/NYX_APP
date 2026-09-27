// lib/widgets/accountWidgets/logout_button.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/dashboard/presentation/main_dashboard.dart';
import 'package:nyxproject/features/cart/domain/cart_service.dart';
import 'package:nyxproject/core/storage/session_manager.dart';

class LogoutButton extends StatelessWidget {
  final SessionService sessionService;
  final CartService? cartService;

  const LogoutButton({
    super.key,
    required this.sessionService,
    this.cartService,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await sessionService.logout();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MainDashboard(
                sessionService: sessionService,
                cartService: cartService,
              ),
            ),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text(
          "Logout",
          style: TextStyle(color: Colors.white, fontFamily: 'Custom'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        ),
      ),
    );
  }
}