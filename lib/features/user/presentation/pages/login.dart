import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nyxproject/features/user/presentation/pages/forgetpassword.dart';
import 'package:nyxproject/features/user/presentation/pages/signup.dart';
import 'package:nyxproject/features/dashboard/presentation/pages/layout.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/presentation/bloc/login_controller.dart';

class LoginPage extends StatefulWidget {
  final SessionService sessionService;
  final CartService? cartService;

  const LoginPage({super.key, required this.sessionService, this.cartService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _muted = Color(0xFF7B8491);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController.forSession(widget.sessionService);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _loginController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _welcomeSection(),

                    const SizedBox(height: 30),

                    _inputForm(),

                    const SizedBox(height: 10),

                    _forgotPassword(),

                    const SizedBox(height: 25),

                    _login(),

                    const SizedBox(height: 25),

                    _signupSection(),

                    const SizedBox(height: 24),

                    _bottomDivider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header
  Widget _header() {
    return Container(
      width: double.infinity,
      color: _navy,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => MainDashboard(
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
              size: 20,
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Welcome section
  Widget _welcomeSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.user,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Welcome Back!',
            style: TextStyle(
              color: _navy,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Sign in to continue your NYX experience.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  // Input form
  Widget _inputForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Email'),

          const SizedBox(height: 8),

          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            style: const TextStyle(color: _navy, fontSize: 14),
            decoration: _inputDecoration(
              hint: 'Enter your email',
              icon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter email';
              }

              if (!RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(value.trim())) {
                return 'Enter a valid email address';
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          _fieldLabel('Password'),

          const SizedBox(height: 8),

          TextFormField(
            controller: passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            style: const TextStyle(color: _navy, fontSize: 14),
            decoration:
                _inputDecoration(
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _muted,
                      size: 20,
                    ),
                  ),
                ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter password';
              }

              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _navy,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 13),
      prefixIcon: Icon(icon, color: _navy, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E9EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E9EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
    );
  }

  // Forgot password
  Widget _forgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          final email = emailController.text.trim();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ForgetPassword(email: email)),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: _red,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // Login button
  Widget _login() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: BlocBuilder<LoginController, LoginState>(
        bloc: _loginController,
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              disabledBackgroundColor: _red.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // Login logic
  Future<void> _handleLogin() async {
    if (_loginController.state.isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();

    try {
      final authenticatedUser = await _loginController.login(
        emailOrPhone: email,
        password: passwordController.text,
      );

      if (!mounted) return;

      if (authenticatedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _loginController.state.errorMessage ??
                  'Invalid email or password',
            ),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          backgroundColor: _navy,
          behavior: SnackBarBehavior.floating,
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
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Signup section
  Widget _signupSection() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SignupPage(
                    sessionService: widget.sessionService,
                    cartService: widget.cartService,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: _red,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'NYX',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}
