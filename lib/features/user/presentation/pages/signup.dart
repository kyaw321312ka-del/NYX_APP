import 'package:flutter/material.dart';
import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/features/user/presentation/pages/otp_page.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:nyxproject/features/user/presentation/pages/terms.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/user/presentation/bloc/user_flow_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  final SessionService sessionService;
  final CartService? cartService;

  const SignupPage({super.key, required this.sessionService, this.cartService});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _muted = Color(0xFF7B8491);

  final formKey = GlobalKey<FormState>();

  bool _isChecked = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late final UserFlowCubit _userFlowCubit;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFlowCubit = UserFlowCubit.forSession(widget.sessionService);
  }

  // Myanmar phone number validation
  String? _validateMyanmarPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }

    final cleanedNumber = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    if (!RegExp(r'^(09|959)[0-9]{7,9}$').hasMatch(cleanedNumber)) {
      return 'Enter a valid Myanmar phone number';
    }

    if (cleanedNumber.startsWith('09')) {
      if (cleanedNumber.length < 9 || cleanedNumber.length > 11) {
        return "Phone number must be 9-11 digits including '09'";
      }
    } else if (cleanedNumber.startsWith('959')) {
      if (cleanedNumber.length < 10 || cleanedNumber.length > 12) {
        return "Phone number must be 10-12 digits including '959'";
      }
    }

    return null;
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        dobController.text =
            '${pickedDate.year}-'
            '${pickedDate.month.toString().padLeft(2, '0')}-'
            '${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    _userFlowCubit.close();
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
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _welcomeSection(),

                      const SizedBox(height: 28),

                      _sectionTitle(
                        'Personal Information',
                        'Tell us a little about yourself.',
                      ),

                      const SizedBox(height: 18),

                      _nameField(),

                      const SizedBox(height: 16),

                      _emailField(),

                      const SizedBox(height: 16),

                      _phoneField(),

                      const SizedBox(height: 16),

                      _dateOfBirthField(),

                      const SizedBox(height: 26),

                      _passwordField(),

                      const SizedBox(height: 16),

                      _confirmPasswordField(),

                      const SizedBox(height: 24),

                      _termsSection(),

                      const SizedBox(height: 24),

                      _signupButton(),

                      const SizedBox(height: 18),

                      _loginSection(),

                      const SizedBox(height: 22),

                      _bottomDivider(),
                    ],
                  ),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Create Account',
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
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Join NYX Today!',
            style: TextStyle(
              color: _navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Create your account and enjoy the NYX experience.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }

  // Shared field decoration
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 13),
      prefixIcon: Icon(icon, color: _navy, size: 20),
      suffixIcon: suffixIcon,
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

  Widget _nameField() {
    return TextFormField(
      controller: nameController,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: _navy, fontSize: 14),
      decoration: _inputDecoration(
        hint: 'Full Name',
        icon: Icons.person_outline_rounded,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      style: const TextStyle(color: _navy, fontSize: 14),
      decoration: _inputDecoration(
        hint: 'Email Address',
        icon: Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter email';
        }

        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
          return 'Enter a valid email address';
        }

        return null;
      },
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: _navy, fontSize: 14),
      decoration:
          _inputDecoration(
            hint: 'Phone Number (09XXXXXXXXX)',
            icon: Icons.phone_outlined,
          ).copyWith(
            helperText: 'Example: 092225305 or 0971234567',
            helperStyle: const TextStyle(color: _muted, fontSize: 11),
          ),
      validator: _validateMyanmarPhoneNumber,
    );
  }

  Widget _dateOfBirthField() {
    return TextFormField(
      controller: dobController,
      readOnly: true,
      onTap: _selectDate,
      style: const TextStyle(color: _navy, fontSize: 14),
      decoration: _inputDecoration(
        hint: 'Date of Birth',
        icon: Icons.calendar_month_outlined,
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _muted,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your date of birth';
        }
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: _navy, fontSize: 14),
      decoration: _inputDecoration(
        hint: 'Create Password',
        icon: Icons.lock_outline_rounded,
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
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: _navy, fontSize: 14),
      decoration: _inputDecoration(
        hint: 'Confirm Password',
        icon: Icons.lock_reset_rounded,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _muted,
            size: 20,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirm password';
        }

        if (value != passwordController.text) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }

  // Terms and conditions
  Widget _termsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: _isChecked,
                  activeColor: _red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'I have read and agree to the Terms & Conditions and Privacy Policy.',
                    style: TextStyle(color: _navy, fontSize: 12, height: 1.5),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Wrap(
              spacing: 4,
              children: [
                _termsLink('Terms & Conditions', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsPage()),
                  );
                }),
                const Text('•', style: TextStyle(color: _muted)),
                _termsLink('Privacy Policy', () {
                  // Connect this to your Privacy Policy page.
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _termsLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: _red,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // Signup button
  Widget _signupButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: BlocBuilder<UserFlowCubit, UserFlowState>(
        bloc: _userFlowCubit,
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state.isLoading ? null : _handleSignUp,
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
                        'CREATE ACCOUNT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
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

  // Signup logic
  Future<void> _handleSignUp() async {
    if (_userFlowCubit.state.isLoading) return;

    if (!formKey.currentState!.validate()) return;

    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final formattedDate = dobController.text.trim();

    try {
      final challenge = await _userFlowCubit.signup(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        dateOfBirth: formattedDate,
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OTP(
            email: challenge.email,
            tempToken: challenge.tempToken,
            password: passwordController.text,
            sessionService: widget.sessionService,
            cartService: widget.cartService,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : 'Error: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Login navigation
  Widget _loginSection() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginPage(
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
              'Login',
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
