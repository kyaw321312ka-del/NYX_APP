// lib/widgets/accountWidgets/login_prompt_card.dart
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Login to your account.",
              style: TextStyle(
                fontFamily: "Custom",
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        sessionService: sessionService,
                        cartService: cartService,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                "or",
                style: TextStyle(
                  fontFamily: "Custom",
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage(
                        sessionService: sessionService,
                        cartService: cartService,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}