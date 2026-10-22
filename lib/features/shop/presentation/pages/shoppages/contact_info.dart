import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:nyxproject/features/shop/domain/usecases/validate_shop_session.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_session_cubit.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/shop_payment.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';

class ContactInfo extends StatelessWidget {
  const ContactInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ShopRepositoryImpl();
    final token = context.read<SessionService>().getToken();
    return BlocProvider(
      create: (_) =>
          ShopSessionCubit(validateSession: ValidateShopSession(repository))
            ..validate(token),
      child: const _ContactInfoForm(),
    );
  }
}

class _ContactInfoForm extends StatefulWidget {
  const _ContactInfoForm();

  @override
  State<_ContactInfoForm> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<_ContactInfoForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  void _showSessionExpiredDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
          'Your session has expired. Please login again to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final sessionService = Provider.of<SessionService>(
                context,
                listen: false,
              );
              final cartService = Provider.of<CartService>(
                context,
                listen: false,
              );
              final navigator = Navigator.of(context);
              await sessionService.logout();
              if (!mounted || !navigator.mounted) return;
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    sessionService: sessionService,
                    cartService: cartService,
                  ),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

    // Show loading while checking token
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verifying session...'),
            ],
          ),
        ),
      );
    }

    // If session expired, show error screen
    if (!isSessionValid) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_off_outlined, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "Session Expired",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                state.errorMessage ??
                    "Your session has expired. Please login again.",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final sessionService = Provider.of<SessionService>(
                    context,
                    listen: false,
                  );
                  final cartService = Provider.of<CartService>(
                    context,
                    listen: false,
                  );
                  final navigator = Navigator.of(context);
                  await sessionService.logout();
                  if (!mounted || !navigator.mounted) return;
                  navigator.pushAndRemoveUntil(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    // Session is valid - show the form
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _section("Contact Information"),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      label: "Full Name",
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      hintText: "Enter your full name",
                      isRequired: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: "Phone Number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      hintText: "09 xxx xxx xxx",
                      isRequired: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: "Email Address",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      hintText: "example@gmail.com",
                      isRequired: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: "Delivery Address",
                      controller: addressController,
                      keyboardType: TextInputType.streetAddress,
                      hintText: "Enter your address",
                      isRequired: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: "Remark",
                      controller: remarkController,
                      keyboardType: TextInputType.text,
                      hintText: "Any special instructions?",
                      isRequired: false,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _continue(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String hintText,
    required bool isRequired,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontFamily: 'Custom',
                    color: Color.fromARGB(255, 13, 27, 42),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Custom',
                color: Colors.grey,
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 13, 27, 42),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (isRequired) {
                if (value == null || value.isEmpty) {
                  return "$label is required";
                }
              }
              if (label == "Email Address" &&
                  value != null &&
                  value.isNotEmpty) {
                if (!value.contains('@') || !value.contains('.')) {
                  return "Enter a valid email address";
                }
              }
              if (label == "Phone Number" &&
                  value != null &&
                  value.isNotEmpty) {
                if (value.length < 9 || value.length > 11) {
                  return "Enter a valid phone number";
                }
              }
              return null;
            },
          ),
        ],
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
              "Information",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 13, 27, 42),
            fontWeight: FontWeight.w900,
            fontFamily: 'Custom',
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _continue() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _validateAndContinue,
        label: const Text(
          "Continue",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Custom",
            fontSize: 15,
          ),
        ),
        icon: const Icon(Icons.arrow_right_alt_sharp, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  void _validateAndContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cartService = Provider.of<CartService>(context, listen: false);
    final totalAmount = cartService.totalPrice;

    Map<String, String> contactInfo = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'address': addressController.text.trim(),
      'remark': remarkController.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Payment(totalAmount: totalAmount, contactInfo: contactInfo),
      ),
    );
  }
}
