import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String currentOption = "Cash on Delivery";
  final TextEditingController input = TextEditingController();
  File? _transactionImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _refreshPaymentData() async {
    final token = context.read<SessionService>().getToken();
    await context.read<ShopCheckoutCubit>().load(token: token);
  }

  double get _taxRate => context.read<ShopCheckoutCubit>().state.taxRate;

  // Calculate tax amount
  double get _taxAmount {
    final subtotal = widget.totalAmount ?? 0;
    return subtotal * (_taxRate / 100);
  }

  // Calculate grand total
  double get _grandTotal {
    final subtotal = widget.totalAmount ?? 0;
    return subtotal + _taxAmount;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Upload Transaction Slip',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 28),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 28),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromGallery();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        if (!mounted) return;
        setState(() {
          _transactionImage = File(image.path);
        });
      }
    } catch (_) {
      return;
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        if (!mounted) return;
        setState(() {
          _transactionImage = File(image.path);
        });
      }
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopCheckoutCubit, ShopCheckoutState>(
      listenWhen: (previous, current) =>
          previous.orderResponse != current.orderResponse ||
          previous.submitError != current.submitError,
      listener: (context, state) {
        if (state.submitError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError!),
              backgroundColor: Colors.red,
            ),
          );
        }

        final orderResponse = state.orderResponse?['data'];
        if (orderResponse is Map<String, dynamic>) {
          context.read<CartService>().clearCart();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SlipPage(
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
          final subtotal = widget.totalAmount ?? 0;
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
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshPaymentData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 5),
                      _section("Contact Information"),
                      const SizedBox(height: 5),
                      _information("name", contactInfo['name'] ?? 'N/A'),
                      const SizedBox(height: 5),
                      _information(
                        "Phone Number",
                        contactInfo['phone'] ?? 'N/A',
                      ),
                      const SizedBox(height: 5),
                      _information(
                        "Email Address",
                        contactInfo['email'] ?? 'N/A',
                      ),
                      const SizedBox(height: 5),
                      _information(
                        "Delivery Address",
                        contactInfo['address'] ?? 'N/A',
                      ),
                      const SizedBox(height: 10),
                      _information("Remark", contactInfo['remark'] ?? 'N/A'),
                      const SizedBox(height: 10),

                      const Divider(),
                      _information1(
                        "Subtotal",
                        "${subtotal.toStringAsFixed(0)} Ks",
                      ),
                      const SizedBox(height: 5),
                      _information(
                        "Tax (${_taxRate.toStringAsFixed(0)}%)",
                        "${_taxAmount.toStringAsFixed(0)} Ks",
                      ),
                      const SizedBox(height: 5),
                      _information1(
                        "Grand Total",
                        "${_grandTotal.toStringAsFixed(0)} Ks",
                      ),
                      const Divider(),
                      _section("Select Payment Method"),
                      const SizedBox(height: 5),
                      _paymentMethod(checkoutState),
                      const SizedBox(height: 5),
                      _paymentInfo(checkoutState),
                      const SizedBox(height: 10),
                      if (_showTransactionInput()) ...[_imageUploadSection()],
                      const SizedBox(height: 20),
                      _confirm(checkoutState),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _showTransactionInput() {
    return currentOption != "Cash on Delivery";
  }

  Widget _imageUploadSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transaction Slip:",
                style: TextStyle(
                  fontFamily: 'Custom',
                  color: Color.fromARGB(255, 13, 27, 42),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text("Upload Slip"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 13, 27, 42),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_transactionImage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _transactionImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => _pickImage(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Change"),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _transactionImage = null;
                        });
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text("Remove"),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
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
              "Payment",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Color.fromARGB(255, 13, 27, 42),
          fontWeight: FontWeight.w600,
          fontFamily: 'Custom',
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _information(String right, String left) {
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            right,
            style: const TextStyle(
              color: Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              left,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color.fromARGB(255, 13, 27, 42),
                fontWeight: FontWeight.w500,
                fontFamily: 'Custom',
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _information1(String right, String left) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            right,
            style: const TextStyle(
              color: Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w700,
              fontFamily: 'Custom',
              fontSize: 17,
            ),
          ),
          Text(
            left,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w700,
              fontFamily: 'Custom',
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethod(ShopCheckoutState state) {
    if (state.isLoadingPaymentMethods) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.paymentMethodsError != null) {
      return Center(
        child: Column(
          children: [
            Text(
              state.paymentMethodsError!,
              style: const TextStyle(color: Colors.red),
            ),
            TextButton(
              onPressed: _refreshPaymentData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    List<String> displayOptions = [];

    for (var method in state.paymentMethods) {
      if (!displayOptions.contains(method.paymentMethod)) {
        displayOptions.add(method.paymentMethod);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: RadioGroup<String>(
        groupValue: currentOption,
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            currentOption = value;
            input.clear();
          });
        },
        child: Column(
          children: displayOptions.map((option) {
            return ListTile(
              title: Text(
                option,
                style: const TextStyle(
                  fontFamily: 'Custom',
                  color: Color.fromARGB(255, 13, 27, 42),
                ),
              ),
              leading: Radio<String>(value: option),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _paymentInfo(ShopCheckoutState state) {
    if (currentOption == "Cash on Delivery") {
      return const SizedBox.shrink();
    }

    PaymentMethod? selectedMethod;
    for (var method in state.paymentMethods) {
      if (method.paymentMethod.toLowerCase() == currentOption.toLowerCase()) {
        selectedMethod = method;
        break;
      }
    }

    if (selectedMethod == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (selectedMethod.paymentImageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Image.network(
                selectedMethod.paymentImageUrl,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.account_balance,
                    size: 40,
                    color: Colors.white,
                  );
                },
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Account Name : ",
                style: TextStyle(
                  fontFamily: 'Custom',
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                selectedMethod.paymentName,
                style: const TextStyle(
                  fontFamily: 'Custom',
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Account Number : ",
                style: TextStyle(
                  fontFamily: 'Custom',
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                selectedMethod.paymentNumber,
                style: const TextStyle(
                  fontFamily: 'Custom',
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _confirm(ShopCheckoutState state) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          fixedSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: state.isSubmitting ? null : _processOrder,
        child: state.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Confirm Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Custom",
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Future<void> _processOrder() async {
    if (_showTransactionInput() && _transactionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload transaction slip'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final cartService = context.read<CartService>();
    final sessionService = context.read<SessionService>();
    final userId = sessionService.getStoredUser()?.id ?? 0;
    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
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
