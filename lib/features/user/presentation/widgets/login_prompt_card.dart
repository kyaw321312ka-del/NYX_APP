import 'package:flutter/material.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:nyxproject/features/user/presentation/pages/signup.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';

class LoginPromptCard extends StatelessWidget {
  final SessionService sessionService;
  final CartService? cartService;

  const LoginPromptCard({
    super.key,
    required this.sessionService,
    this.cartService,
  });

  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  static const Color _muted = Color(0xFF788292);
  static const Color _border = Color(0xFFEAECF0);

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LoginPage(sessionService: sessionService, cartService: cartService),
      ),
    );
  }

  void _openSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupPage(
          sessionService: sessionService,
          cartService: cartService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row(
          //   children: [
          //     Container(
          //       width: 44,
          //       height: 44,
          //       decoration: BoxDecoration(
          //         color: const Color(0xFFFFECEE),
          //         borderRadius: BorderRadius.circular(13),
          //       ),
          //       child: const Icon(
          //         Icons.person_outline_rounded,
          //         color: _red,
          //         size: 25,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     const Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Welcome to NYX',
          //             style: TextStyle(
          //               color: _navy,
          //               fontSize: 16,
          //               fontWeight: FontWeight.w700,
          //             ),
          //           ),
          //           SizedBox(height: 4),
          //           Text(
          //             'Sign in to access your account.',
          //             style: TextStyle(
          //               color: _muted,
          //               fontSize: 12,
          //               height: 1.4,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 18),

          // Primary action
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _openLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Login to your account',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary action
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => _openSignup(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _navy,
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Create an account',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
