import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/core/presentation/widgets/cors_safe_network_image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nyxproject/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:nyxproject/features/orders/domain/entities/payment.dart';
import 'package:nyxproject/features/shop/domain/entities/shop_order_request.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_shop_payment_methods.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_shop_tax.dart';
import 'package:nyxproject/features/shop/domain/usecases/place_shop_order.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_checkout_cubit.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_checkout_state.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/slip.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';

const Color _navy = Color(0xFF0D1B2A);
const Color _red = Color(0xFFEF3340);
const Color _background = Color(0xFFF7F8FA);
const Color _muted = Color(0xFF7B8490);
const Color _border = Color(0xFFE7EAF0);

class Payment extends StatelessWidget {
  final double? totalAmount;
  final Map<String, String>? contactInfo;

  const Payment({super.key, this.totalAmount, this.contactInfo});

  @override
  Widget build(BuildContext context) {
    final repository = ShopRepositoryImpl();
    final token = context.read<SessionService>().getToken();

    return BlocProvider(
      create: (_) => ShopCheckoutCubit(
        getPaymentMethods: GetShopPaymentMethods(repository),
        getTax: GetShopTax(repository),
        placeOrder: PlaceShopOrder(repository),
      )..load(token: token),
      child: _PaymentContent(
        totalAmount: totalAmount,
        contactInfo: contactInfo,
      ),
    );
  }
}

class _PaymentContent extends StatefulWidget {
  final double? totalAmount;
  final Map<String, String>? contactInfo;

  const _PaymentContent({this.totalAmount, this.contactInfo});

  @override
  State<_PaymentContent> createState() => _PaymentState();
}

class _PaymentState extends State<_PaymentContent> {
  String currentOption = 'Cash on Delivery';

  final TextEditingController input = TextEditingController();
  File? _transactionImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> _refreshPaymentData() async {
    final token = context.read<SessionService>().getToken();
    await context.read<ShopCheckoutCubit>().load(token: token);
  }

  double get _taxRate => context.read<ShopCheckoutCubit>().state.taxRate;

  double get _taxAmount {
    final subtotal = widget.totalAmount ?? 0;
    return subtotal * (_taxRate / 100);
  }

  double get _grandTotal {
    final subtotal = widget.totalAmount ?? 0;
    return subtotal + _taxAmount;
  }

  String _formatPrice(double amount) {
    return '${amount.toStringAsFixed(0)} Ks';
  }

  Future<void> _pickImage() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 18),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'Upload Transaction Slip',
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: _navy),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: _navy),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickImageFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _transactionImage = File(image.path);
        });
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to open camera. Please try again.', isError: true);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _transactionImage = File(image.path);
        });
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to select image. Please try again.', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _red : _navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopCheckoutCubit, ShopCheckoutState>(
      listenWhen: (previous, current) =>
          previous.orderResponse != current.orderResponse ||
          previous.submitError != current.submitError,
      listener: (context, state) {
        if (state.submitError != null) {
          _showMessage(state.submitError!, isError: true);
        }

        final orderResponse = state.orderResponse?['data'];

        if (orderResponse is Map<String, dynamic>) {
          context.read<CartService>().clearCart();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SlipPage(
                paymentMethod: currentOption,
                transactionNumber: input.text.trim(),
                totalAmount: _grandTotal,
                subTotal: widget.totalAmount ?? 0,
                taxRate: _taxRate,
                taxAmount: _taxAmount,
                contactInfo: widget.contactInfo,
                orderResponse: orderResponse,
              ),
            ),
          );
        }
      },
      child: BlocBuilder<ShopCheckoutCubit, ShopCheckoutState>(
        builder: (context, checkoutState) {
          final contactInfo =
              widget.contactInfo ??
              {
                'name': 'N/A',
                'phone': 'N/A',
                'email': 'N/A',
                'address': 'N/A',
                'remark': 'N/A',
              };

          return Scaffold(
            backgroundColor: _background,
            body: SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: RefreshIndicator(
                      color: _red,
                      onRefresh: _refreshPaymentData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _pageIntroduction(),
                            const SizedBox(height: 24),

                            _sectionTitle(
                              'Order Information',
                              'Review your delivery details.',
                              Icons.receipt_long_outlined,
                            ),
                            const SizedBox(height: 14),
                            _contactCard(contactInfo),

                            const SizedBox(height: 24),

                            _sectionTitle(
                              'Order Summary',
                              'Your payment breakdown.',
                              Icons.account_balance_wallet_outlined,
                            ),
                            const SizedBox(height: 14),
                            _summaryCard(),

                            const SizedBox(height: 24),

                            _sectionTitle(
                              'Payment Method',
                              'Choose how you want to pay.',
                              Icons.payments_outlined,
                            ),
                            const SizedBox(height: 14),
                            _paymentMethod(checkoutState),

                            const SizedBox(height: 14),
                            _paymentInfo(checkoutState),

                            if (_showTransactionInput()) ...[
                              const SizedBox(height: 20),
                              _imageUploadSection(),
                            ],

                            const SizedBox(height: 26),
                            _confirm(checkoutState),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
              'Payment',
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
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
                  'Complete Your Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Review your details and select a payment method.',
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
          width: 40,
          height: 40,
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

  Widget _contactCard(Map<String, String> contactInfo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          _contactRow(
            Icons.person_outline_rounded,
            'Full Name',
            contactInfo['name'] ?? 'N/A',
          ),
          _contactRow(
            Icons.phone_outlined,
            'Phone Number',
            contactInfo['phone'] ?? 'N/A',
          ),
          _contactRow(
            Icons.email_outlined,
            'Email Address',
            contactInfo['email'] ?? 'N/A',
          ),
          _contactRow(
            Icons.location_on_outlined,
            'Delivery Address',
            contactInfo['address'] ?? 'N/A',
          ),
          _contactRow(
            Icons.notes_rounded,
            'Remark',
            contactInfo['remark'] ?? 'N/A',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _muted, size: 19),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: _navy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          _priceRow('Subtotal', _formatPrice(widget.totalAmount ?? 0)),
          const SizedBox(height: 14),
          _priceRow(
            'Tax (${_taxRate.toStringAsFixed(0)}%)',
            _formatPrice(_taxAmount),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: _border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  color: _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatPrice(_grandTotal),
                style: const TextStyle(
                  color: _red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: _navy,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _paymentMethod(ShopCheckoutState state) {
    if (state.isLoadingPaymentMethods) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: CircularProgressIndicator(color: _red),
        ),
      );
    }

    if (state.paymentMethodsError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: _red, size: 30),
            const SizedBox(height: 8),
            Text(
              state.paymentMethodsError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _red, fontSize: 13),
            ),
            TextButton(
              onPressed: _refreshPaymentData,
              child: const Text(
                'Retry',
                style: TextStyle(color: _navy, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final displayOptions = <String>[];

    for (final method in state.paymentMethods) {
      if (!displayOptions.contains(method.paymentMethod)) {
        displayOptions.add(method.paymentMethod);
      }
    }

    if (displayOptions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: const Text(
          'No payment methods are currently available.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted),
        ),
      );
    }

    // Keep the current choice only if it is still available.
    if (!displayOptions.contains(currentOption)) {
      currentOption = displayOptions.first;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: RadioGroup<String>(
        groupValue: currentOption,
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            currentOption = value;
            input.clear();
            _transactionImage = null;
          });
        },
        child: Column(
          children: displayOptions.map((option) {
            final selected = currentOption == option;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? _red.withOpacity(0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? _red : Colors.transparent),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: Radio<String>(value: option, activeColor: _red),
                title: Text(
                  option,
                  style: TextStyle(
                    color: _navy,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                trailing: selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: _red,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _paymentInfo(ShopCheckoutState state) {
    if (currentOption.toLowerCase() == 'cash on delivery') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: const Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: _red, size: 25),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'You can pay when your order is delivered.',
                style: TextStyle(color: _navy, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    PaymentMethod? selectedMethod;

    for (final method in state.paymentMethods) {
      if (method.paymentMethod.toLowerCase() == currentOption.toLowerCase()) {
        selectedMethod = method;
        break;
      }
    }

    if (selectedMethod == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: Colors.white,
                size: 21,
              ),
              SizedBox(width: 10),
              Text(
                'Payment Account Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (selectedMethod.paymentImageUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CorsSafeNetworkImage.network(
                  selectedMethod.paymentImageUrl,
                  height: 65,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.account_balance,
                      size: 40,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          _accountRow('Account Name', selectedMethod.paymentName),
          const SizedBox(height: 14),
          _accountRow('Account Number', selectedMethod.paymentNumber),
        ],
      ),
    );
  }

  Widget _accountRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 5),
        SelectableText(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  bool _showTransactionInput() {
    return currentOption.toLowerCase() != 'cash on delivery';
  }

  Widget _imageUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: _red, size: 21),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Transaction Slip',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Required',
                style: TextStyle(
                  color: _red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload a clear screenshot or photo of your payment receipt.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),

          if (_transactionImage == null)
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _red.withOpacity(0.4),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: _red, size: 38),
                    SizedBox(height: 10),
                    Text(
                      'Upload Payment Slip',
                      style: TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tap to take a photo or choose from gallery',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _transactionImage!,
                width: double.infinity,
                height: 190,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    color: _background,
                    child: const Text(
                      'Unable to preview selected image.',
                      style: TextStyle(color: _muted),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Change'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _navy,
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _transactionImage = null;
                      });
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _confirm(ShopCheckoutState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total to Pay',
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatPrice(_grandTotal),
              style: const TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: state.isSubmitting ? null : _processOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _red.withOpacity(0.5),
              elevation: 2,
              shadowColor: _red.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: state.isSubmitting
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
                      Icon(Icons.lock_outline_rounded, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Confirm Payment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, size: 14, color: _muted),
            SizedBox(width: 6),
            Text(
              'Please review your order before confirming.',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _processOrder() async {
    if (_showTransactionInput() && _transactionImage == null) {
      _showMessage('Please upload transaction slip.', isError: true);
      return;
    }

    final cartService = context.read<CartService>();
    final sessionService = context.read<SessionService>();

    final userId = sessionService.getStoredUser()?.id ?? 0;

    if (userId == 0) {
      _showMessage('User not found. Please login again.', isError: true);
      return;
    }

    final contactInfo = widget.contactInfo ?? {};

    final items = cartService.items
        .map(
          (item) => {'product_id': item.product.id, 'quantity': item.quantity},
        )
        .toList();

    await context.read<ShopCheckoutCubit>().placeOrder(
      ShopOrderRequest(
        userId: userId,
        customerName: contactInfo['name'] ?? '',
        phone: contactInfo['phone'] ?? '',
        email: contactInfo['email'] ?? '',
        deliveryAddress: contactInfo['address'] ?? '',
        remark: contactInfo['remark'] ?? '',
        paymentMethod: currentOption.toLowerCase(),
        items: items,
        tax: _taxAmount,
        totalAmount: _grandTotal,
        token: sessionService.getToken(),
        transactionNumber: input.text.trim(),
        transactionImage: _transactionImage,
      ),
    );
  }
}
