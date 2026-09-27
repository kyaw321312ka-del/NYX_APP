import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyxproject/core/constants/app_constants.dart';
import 'package:nyxproject/features/orders/data/PaymentApi.dart';
import 'package:nyxproject/features/shop/data/TaxApi.dart'; // Add this import
import 'package:nyxproject/features/orders/domain/Payment.dart';
import 'package:nyxproject/features/shop/domain/Tax.dart'; // Add this import
import 'package:provider/provider.dart';
import 'package:nyxproject/features/shop/presentation/shoppages/slip.dart';
import 'package:nyxproject/features/cart/domain/cart_service.dart';
import 'package:nyxproject/core/storage/session_manager.dart';

class Payment extends StatefulWidget {
  final double? totalAmount;
  final Map<String, String>? contactInfo;

  const Payment({super.key, this.totalAmount, this.contactInfo});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String currentOption = "Cash on Delivery";
  final TextEditingController input = TextEditingController();
  File? _transactionImage;
  bool _isProcessing = false;
  bool _isLoadingPayments = true;
  bool _isLoadingTax = true; // Add this
  final ImagePicker _picker = ImagePicker();

  List<PaymentMethod> _paymentMethods = [];
  Tax? _tax; // Add this variable
  double _taxRate = 0; // Add this variable

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
    _fetchTax(); // Add this
  }

  // Add this method to fetch tax
  Future<void> _fetchTax() async {
    setState(() {
      _isLoadingTax = true;
    });

    try {
      final result = await TaxApi.getTax();

      if (result['success']) {
        setState(() {
          _tax = result['tax'];
          _taxRate = _tax?.tax.toDouble() ?? 0;
          _isLoadingTax = false;
        });
        print(' Tax loaded: ${_tax?.tax}%');
      } else {
        setState(() {
          _isLoadingTax = false;
          // Default to 5% if API fails
          _taxRate = 5;
        });
        print("Error fetching tax: ${result['message']}");
      }
    } catch (e) {
      setState(() {
        _isLoadingTax = false;
        _taxRate = 5; // Default fallback
      });
      print("Error: $e");
    }
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() {
      _isLoadingPayments = true;
    });

    try {
      final sessionService = Provider.of<SessionService>(
        context,
        listen: false,
      );
      final token = sessionService.getToken();

      final result = await PaymentApi.getPaymentMethods(token: token);

      if (result['success']) {
        setState(() {
          _paymentMethods = result['data'];
          _isLoadingPayments = false;
        });
      } else {
        setState(() {
          _isLoadingPayments = false;
        });
        print("Error fetching payment methods: ${result['message']}");
      }
    } catch (e) {
      setState(() {
        _isLoadingPayments = false;
      });
      print("Error: $e");
    }
  }

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
        setState(() {
          _transactionImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
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
        setState(() {
          _transactionImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 5),
              _section("Contact Information"),
              const SizedBox(height: 5),
              _information("Name", contactInfo['name'] ?? 'N/A'),
              const SizedBox(height: 5),
              _information("Phone Number", contactInfo['phone'] ?? 'N/A'),
              const SizedBox(height: 5),
              _information("Email Address", contactInfo['email'] ?? 'N/A'),
              const SizedBox(height: 5),
              _information("Delivery Address", contactInfo['address'] ?? 'N/A'),
              const SizedBox(height: 10),
              _information("Remark", contactInfo['remark'] ?? 'N/A'),
              const SizedBox(height: 10),

              const Divider(),
              _information1("Subtotal", "${subtotal.toStringAsFixed(0)} Ks"),
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
              _paymentMethod(),
              const SizedBox(height: 5),
              _paymentInfo(),
              const SizedBox(height: 10),
              if (_showTransactionInput()) ...[_imageUploadSection()],
              const SizedBox(height: 20),
              _confirm(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Add tax section widget
  Widget _taxSection() {
    if (_isLoadingTax) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Tax",
              style: TextStyle(
                color: Color.fromARGB(255, 13, 27, 42),
                fontWeight: FontWeight.w500,
                fontFamily: 'Custom',
                fontSize: 15,
              ),
            ),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Tax (${_taxRate.toStringAsFixed(0)}%)",
            style: const TextStyle(
              color: Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: 15,
            ),
          ),
          Text(
            "${_taxAmount.toStringAsFixed(0)} Ks",
            style: const TextStyle(
              color: Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: 15,
            ),
          ),
        ],
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

  Widget _paymentMethod() {
    if (_isLoadingPayments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    List<String> displayOptions = [];

    for (var method in _paymentMethods) {
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
            leading: Radio(
              value: option,
              groupValue: currentOption,
              onChanged: (value) {
                setState(() {
                  currentOption = value.toString();
                  input.clear();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _paymentInfo() {
    if (currentOption == "Cash on Delivery") {
      return const SizedBox.shrink();
    }

    PaymentMethod? selectedMethod;
    for (var method in _paymentMethods) {
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

  Widget _confirm() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          fixedSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: _isProcessing ? null : _processOrder,
        child: _isProcessing
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
    if (_showTransactionInput()) {
      if (_transactionImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload transaction slip'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      final sessionService = Provider.of<SessionService>(
        context,
        listen: false,
      );

      final user = sessionService.getStoredUser();
      final userId = user?.id ?? 0;
      final token = sessionService.getToken();

      if (userId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final itemsList = cartService.items.map((item) {
        return {'product_id': item.product.id, 'quantity': item.quantity};
      }).toList();

      final itemsJsonString = jsonEncode(itemsList);
      final deliveryFee = 0;
      final contactInfo = widget.contactInfo ?? {};

      final Uri uri = Uri.parse("${Constant.API_URL}/cart/order");
      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.fields['user_id'] = userId.toString();
      request.fields['customer_name'] = contactInfo['name'] ?? '';
      request.fields['phone'] = contactInfo['phone'] ?? '';
      request.fields['email'] = contactInfo['email'] ?? '';
      request.fields['delivery_address'] = contactInfo['address'] ?? '';
      request.fields['remark'] = contactInfo['remark'] ?? '';
      request.fields['payment_method'] = currentOption.toLowerCase();
      request.fields['items'] = itemsJsonString;
      request.fields['tax'] = _taxAmount.toString(); // Use calculated tax
      request.fields['delivery_fee'] = deliveryFee.toString();
      request.fields['total_amount'] = _grandTotal
          .toString(); // Add grand total

      if (input.text.trim().isNotEmpty) {
        request.fields['transaction_number'] = input.text.trim();
      }

      if (_transactionImage != null) {
        request.fields['has_slip'] = 'true';
        request.files.add(
          await http.MultipartFile.fromPath('image', _transactionImage!.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() {
        _isProcessing = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        cartService.clearCart();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => slipPage(
                paymentMethod: currentOption,
                transactionNumber: input.text.trim(),
                totalAmount: _grandTotal, // Use grand total
                subTotal: widget.totalAmount ?? 0,
                taxRate: _taxRate,
                taxAmount: _taxAmount,
                contactInfo: widget.contactInfo,
                orderResponse: responseData,
              ),
            ),
          );
        }
      } else {
        String errorMessage = 'Failed to place order';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network Error: Please check your connection'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
