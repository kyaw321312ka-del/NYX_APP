import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:nyxproject/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:nyxproject/features/shop/domain/usecases/validate_shop_session.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_session_cubit.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/shop_payment.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';

const Color _navy = Color(0xFF0D1B2A);
const Color _red = Color(0xFFEF3340);
const Color _background = Color(0xFFF7F8FA);
const Color _muted = Color(0xFF7B8490);

class ContactInfo extends StatelessWidget {
  const ContactInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ShopRepositoryImpl();
    final sessionService = context.read<SessionService>();
    final token = sessionService.getToken();
    final user = sessionService.getStoredUser();

    return BlocProvider(
      create: (_) =>
          ShopSessionCubit(validateSession: ValidateShopSession(repository))
            ..validate(token),
      child: _ContactInfoForm(user: user),
    );
  }
}

class _ContactInfoForm extends StatefulWidget {
  const _ContactInfoForm({this.user});

  final User? user;

  @override
  State<_ContactInfoForm> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<_ContactInfoForm> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final remarkController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user?.name ?? '';
    phoneController.text = widget.user?.phone ?? '';
    emailController.text = widget.user?.email ?? '';
    addressController.text = widget.user?.address ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  Future<void> _logoutAndGoToLogin() async {
    final sessionService = context.read<SessionService>();
    final cartService = context.read<CartService>();
    final navigator = Navigator.of(context);

    await sessionService.logout();

    if (!mounted || !navigator.mounted) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            LoginPage(sessionService: sessionService, cartService: cartService),
      ),
      (route) => false,
    );
  }

  void _showSessionExpiredDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.lock_clock_rounded, color: _red, size: 42),
        title: const Text(
          'Session Expired',
          style: TextStyle(color: _navy, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Your session has expired. Please login again to continue.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _logoutAndGoToLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopSessionCubit, ShopSessionState>(
      listener: (context, state) async {
        if (state.status != ShopSessionStatus.invalid) return;

        if (state.shouldLogout) {
          await context.read<SessionService>().logout();
        }

        if (!mounted) return;
        _showSessionExpiredDialog();
      },
      child: BlocBuilder<ShopSessionCubit, ShopSessionState>(
        builder: (context, state) => _buildContent(state),
      ),
    );
  }

  Widget _buildContent(ShopSessionState state) {
    final isLoading = state.status == ShopSessionStatus.loading;
    final isSessionValid = state.status == ShopSessionStatus.valid;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _red),
              SizedBox(height: 16),
              Text(
                'Verifying session...',
                style: TextStyle(color: _navy, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (!isSessionValid) {
      return Scaffold(
        backgroundColor: _background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_clock_rounded,
                    size: 45,
                    color: _red,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Session Expired',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.errorMessage ??
                      'Your session has expired. Please login again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, fontSize: 14),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _logoutAndGoToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Go to Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pageIntroduction(),
                      const SizedBox(height: 26),

                      _sectionTitle(
                        'Contact Information',
                        'Please provide your contact details.',
                        Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'Full Name',
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        hintText: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        isRequired: true,
                      ),
                      _buildTextField(
                        label: 'Phone Number',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        hintText: '09 xxx xxx xxx',
                        icon: Icons.phone_outlined,
                        isRequired: true,
                      ),
                      _buildTextField(
                        label: 'Email Address',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'example@gmail.com',
                        icon: Icons.email_outlined,
                        isRequired: true,
                      ),
                      _buildTextField(
                        label: 'Delivery Address',
                        controller: addressController,
                        keyboardType: TextInputType.streetAddress,
                        hintText: 'Enter your delivery address',
                        icon: Icons.location_on_outlined,
                        isRequired: true,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 8),

                      _sectionTitle(
                        'Additional Information',
                        'Anything else we should know?',
                        Icons.notes_rounded,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'Remark',
                        controller: remarkController,
                        keyboardType: TextInputType.text,
                        hintText: 'Any special instructions? (Optional)',
                        icon: Icons.edit_note_rounded,
                        isRequired: false,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                      _continueButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
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
          const Expanded(
            child: Text(
              'Delivery Information',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _pageIntroduction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Where should we deliver?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Enter your details to continue with your order.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: _red.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _red, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String hintText,
    required IconData icon,
    required bool isRequired,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: _red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            textCapitalization: label == 'Full Name'
                ? TextCapitalization.words
                : TextCapitalization.none,
            style: const TextStyle(color: _navy, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFADB4BD),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: _muted, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE7EAF0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE7EAF0)),
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
            ),
            validator: (value) {
              final input = value?.trim() ?? '';

              if (isRequired && input.isEmpty) {
                return '$label is required';
              }

              if (input.isEmpty) return null;

              if (label == 'Email Address') {
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                if (!emailRegex.hasMatch(input)) {
                  return 'Enter a valid email address';
                }
              }

              if (label == 'Phone Number') {
                final digits = input.replaceAll(RegExp(r'\D'), '');

                if (digits.length < 9 || digits.length > 11) {
                  return 'Enter a valid phone number';
                }
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _validateAndContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: _red.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Payment',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _validateAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    final cartService = context.read<CartService>();
    final totalAmount = cartService.totalPrice;
    final remark = remarkController.text.trim();

    final contactInfo = <String, String>{
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'address': addressController.text.trim(),
      'remark': remark.isEmpty ? 'No additional remarks' : remark,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            Payment(totalAmount: totalAmount, contactInfo: contactInfo),
      ),
    );
  }
}
