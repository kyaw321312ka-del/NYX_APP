// import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/presentation/pages/forgetpassword.dart';
import 'package:nyxproject/features/user/presentation/pages/signup.dart';// Add this import
import 'package:nyxproject/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/core/network/api_client.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';

class LoginPage extends StatefulWidget {
  final SessionService sessionService;
  final CartService? cartService;
  
  const LoginPage({super.key, required this.sessionService, this.cartService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double get screenWidth => MediaQuery.of(context).size.width;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
              _MainIcon(),
              const Divider(),
              _inputform(),
              const SizedBox(height: 10),
              _forgotPassword(), // Forgot Password link
              const SizedBox(height: 10),
              _login(),
              const SizedBox(height: 10),
              _toSignUp(),
              const SizedBox(height: 10),
              // _continuewith("--- or Continue With ---"),
              // const SizedBox(height: 15),
              // _choice(),
              const SizedBox(height: 15),
              const Divider(),
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
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text(
              "Login",
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

  Widget _inputform() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              decoration: InputDecoration(
                hintText: "Email",
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter email";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter password";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Forgot Password Widget - Navigates to ForgetPassword page
  Widget _forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            final email = emailController.text.trim();
            
            // Navigate to ForgetPassword page with email
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgetPassword(
                  email: email.isNotEmpty ? email : '', // Pass email if entered, else empty
                ),
              ),
            );
          },
          child: const Text(
            "Forgot Password?",
            style: TextStyle(
              fontFamily: "Custom",
              fontSize: 13,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidToken(String token) {
    if (token.isEmpty) return false;
    if (token == "Invalid password") return false;
    // Check if token is a valid JWT format (has 3 parts separated by dots)
    final parts = token.split('.');
    if (parts.length != 3) return false;
    return true;
  }

  Widget _login() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(350, 50),
          backgroundColor: Colors.red,
        ),
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "LOGIN",
                style: TextStyle(
                  fontFamily: "Custom",
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      final Map<String, dynamic> loginResult = await Api.loginUser(
        emailOrphone: email,
        password: password,
      );

      if (!mounted) return;

      final bool success = loginResult['success'] == true;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginResult['message']?.toString() ?? "Invalid email or password"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final dynamic rawData = loginResult['data'];
      Map<String, dynamic> responseMap = <String, dynamic>{};
      if (rawData is Map<String, dynamic>) {
        responseMap = rawData;
      }

      final String token = responseMap['token']?.toString() ?? '';

      // Validate token
      if (!_isValidToken(token)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid response from server. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch user profile
      final profileResult = await Api.getMyProfile(token: token);

      User user;

      if (profileResult['success'] == true) {
        final userData = profileResult['data'] as Map<String, dynamic>;
        print("Profile data: $userData");

        user = User(
          id: userData['id'] != null ? int.tryParse(userData['id'].toString()) : null,
          name: userData['name']?.toString(),
          email: userData['email']?.toString() ?? email,
          phone: userData['phone']?.toString(),
          imageUrl: userData['image_url']?.toString(),
          dateOfBirth: userData['dateOfBirth']?.toString(),
          address: userData['address']?.toString(),
        );
      } else {
        final dynamic rawUser = responseMap['user'];
        Map<String, dynamic> userJson = {};

        if (rawUser is Map<String, dynamic>) {
          userJson = rawUser;
        } else {
          userJson = responseMap;
        }

        print("Login response user data: $userJson");

        user = User(
          id: userJson['id'] != null ? int.tryParse(userJson['id'].toString()) : null,
          name: userJson['name']?.toString(),
          email: userJson['email']?.toString() ?? email,
          phone: userJson['phone']?.toString(),
          imageUrl: userJson['image_url']?.toString(),
          dateOfBirth: userJson['dateOfBirth']?.toString(),
          address: userJson['address']?.toString(),
        );
      }

      // Validate user has an ID
      if (user.id == null || user.id == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid user data received'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print("User to save - ID: ${user.id}, Name: ${user.name}, Email: ${user.email}");

      await widget.sessionService.saveSession(user, token);

      final savedUser = widget.sessionService.getStoredUser();
      print("Verified saved user - ID: ${savedUser?.id}, Name: ${savedUser?.name}");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          backgroundColor: Colors.grey,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainDashboard(
            sessionService: widget.sessionService,
            cartService: widget.cartService,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _continuewith(String title) {
    return Center(
      child: Text(title, style: const TextStyle(fontFamily: "Custom", fontSize: 15)),
    );
  }

  Widget _choice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.facebook_rounded),
          label: const Text(
            "Facebook",
            style: TextStyle(
              fontFamily: "Custom",
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 13, 27, 42),
            iconColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const FaIcon(FontAwesomeIcons.google),
          label: const Text(
            "Google",
            style: TextStyle(
              fontFamily: "Custom",
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 13, 27, 42),
            iconColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _MainIcon() {
    return const Center(child: FaIcon(FontAwesomeIcons.user, size: 200));
  }

  Widget _toSignUp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account",
          style: TextStyle(fontFamily: "Custom", fontSize: 15),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SignupPage(
                  sessionService: widget.sessionService,
                  cartService: widget.cartService,
                ),
              ),
            );
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              fontFamily: "Custom",
              fontSize: 15,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}