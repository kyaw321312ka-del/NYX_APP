import 'package:flutter/material.dart';
import 'package:nyxproject/features/user/data/datasources/login_after_signup_api.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/dashboard/presentation/pages/layout.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/core/network/api_client.dart';

class OTP extends StatefulWidget {
  final String email;
  final String tempToken;
  final String password;
  final SessionService sessionService;
  final CartService? cartService;

  const OTP({
    super.key,
    required this.email,
    required this.tempToken,
    required this.password,
    required this.sessionService,
    this.cartService,
  });

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 10),
              _main(),
              const SizedBox(height: 15),
              _verifyBTN(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text(
              "Verification",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _main() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Please verify your email account.",
            style: TextStyle(
              fontFamily: "Custom",
              color: const Color.fromARGB(255, 13, 27, 42),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 13, 27, 42),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.email, color: Colors.white70),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.email,
                    style: const TextStyle(
                      fontFamily: "Custom",
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: otpController,
            style: const TextStyle(
              fontFamily: "Custom",
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            decoration: InputDecoration(
              hintText: "Enter your OTP",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color.fromARGB(255, 13, 27, 42),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.security, color: Colors.white70),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
        ],
      ),
    );
  }

  Widget _verifyBTN() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 50),
          backgroundColor: Colors.red,
        ),
        onPressed: _isLoading ? null : _verifyOtp,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Verify",
                style: TextStyle(
                  fontFamily: "Custom",
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final String otp = otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid 6-digit OTP")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> verifyResult = await Api.verifyOtp(
        otp: otp,
        tempToken: widget.tempToken,
      );

      if (!mounted) return;

      if (verifyResult['success'] == true) {
        final loginResult = await LoginAfterSignupApi.loginAfterSignup(
          widget.email,
          widget.password,
        );
        if (!mounted) return;

        if (loginResult['success'] == true) {
          final token = loginResult['token'];

          // Extract user data from the token or create from email
          // Since the response doesn't have a separate user object,
          // we need to either decode the JWT token or use the email

          // Option 1: Create user from email (temporary)
          final user = User(
            id: null, // Will be updated when fetching profile
            name: widget.email.split('@').first, // Use part before @ as name
            email: widget.email,
            phone: '',
          );

          await widget.sessionService.saveSession(user, token);

          // Optional: Fetch full user profile after login
          // This will get the complete user data including ID and phone
          try {
            final profileResult = await Api.getMyProfile(token: token);
            if (profileResult['success'] == true) {
              final fullUserData = profileResult['data'];
              final updatedUser = User(
                id: fullUserData['id'] as int?,
                name: fullUserData['name']?.toString() ?? user.name,
                email: widget.email,
                phone: fullUserData['phone']?.toString() ?? '',
              );
              await widget.sessionService.saveSession(updatedUser, token);
            }
          } on Exception catch (error) {
            debugPrint('Optional profile enrichment failed: $error');
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created and logged in successfully!"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainDashboard(
                sessionService: widget.sessionService,
                cartService: widget.cartService,
              ),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account verified! Please login manually."),
              backgroundColor: Colors.orange,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                sessionService: widget.sessionService,
                cartService: widget.cartService,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyResult['message']?.toString() ?? "Invalid OTP"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
