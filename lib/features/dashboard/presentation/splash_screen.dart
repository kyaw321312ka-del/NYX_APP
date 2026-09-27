import 'package:flutter/material.dart';
import 'package:nyxproject/core/storage/session_manager.dart';
import 'package:nyxproject/features/cart/domain/cart_service.dart';
import 'package:nyxproject/features/dashboard/presentation/main_dashboard.dart';

class SplashScreen extends StatefulWidget {
  final SessionService sessionService;
  final CartService cartService;

  const SplashScreen({
    super.key,
    required this.sessionService,
    required this.cartService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Minimum splash screen duration (2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Navigate to MainDashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainDashboard(
          sessionService: widget.sessionService,
          cartService: widget.cartService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B263B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/images/logo1.png',
              width: 190,
              height: 190,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return const Text(
                  "NYX",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 13, 27, 42),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 223, 238, 254),
              ),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}