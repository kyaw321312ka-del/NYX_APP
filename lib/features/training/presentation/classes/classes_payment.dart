import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nyxproject/core/constants/app_constants.dart';
import 'package:nyxproject/features/orders/data/PaymentApi.dart';
import 'package:nyxproject/features/orders/domain/Payment.dart';
import 'package:nyxproject/core/storage/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/training/presentation/classes/classes_slip.dart';

class classesPayment extends StatefulWidget {
  final Map<String, dynamic>? enrollmentData;

  const classesPayment({super.key, this.enrollmentData});

  @override
  State<classesPayment> createState() => _classesPaymentState();
}

class _classesPaymentState extends State<classesPayment> {
  String? selectedPaymentId;
  final TextEditingController input = TextEditingController();
  File? _paymentImage;
  bool _isProcessing = false;
  bool _isLoadingPayments = true;
  String? _paymentsError;
  final ImagePicker _picker = ImagePicker();

  List<PaymentMethod> _paymentMethods = [];  // Changed to List<PaymentMethod>

  // Enrollment data
  String fullname = "";
  String gender = "";
  String age = "";
  String address = "";
  String phone = "";
  String email = "";
  String trainingLevel = "";
  String trainingSchedule = "";
  String trainingTitle = "";
  int price = 0;
  int? trainingProgramId;
  int? trainingLevelId;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _loadEnrollmentData();
  }

  void _loadEnrollmentData() {
    final data = widget.enrollmentData ?? {};
    
    setState(() {
      fullname = data['fullname'] ?? "N/A";
      gender = data['gender'] ?? "N/A";
      age = data['age']?.toString() ?? "N/A";
      address = data['address'] ?? "Yangon, Myanmar";
      phone = data['phone'] ?? "N/A";
      email = data['email'] ?? "N/A";
      trainingLevel = data['levelName'] ?? "Beginner Level";
      trainingSchedule = data['timeSlot'] ?? "8:00 - 10:00 AM";
      trainingTitle = data['trainingTitle'] ?? "Training Program";
      price = data['price'] ?? 0;
      trainingProgramId = data['trainingId'];
      trainingLevelId = data['levelId'];
    });
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoadingPayments = true;
      _paymentsError = null;
    });

    try {
      final sessionService = Provider.of<SessionService>(
        context,
        listen: false,
      );
      final token = sessionService.getToken();

      final result = await PaymentApi.getPaymentMethods(token: token);

      if (result['success']) {
        // result['data'] is already List<PaymentMethod>
        final List<PaymentMethod> methods = result['data'];
        
        setState(() {
          _paymentMethods = methods;
          _isLoadingPayments = false;
          if (_paymentMethods.isNotEmpty) {
            selectedPaymentId = _paymentMethods[0].id.toString();
          }
        });
      } else {
        setState(() {
          _paymentsError = result['message'] ?? 'Failed to load payment methods';
          _isLoadingPayments = false;
        });
      }
    } catch (e) {
      print("Error loading payment methods: $e");
      setState(() {
        _paymentsError = 'Error loading payment methods: $e';
        _isLoadingPayments = false;
      });
    }
  }

  PaymentMethod? get selectedPaymentMethod {
    for (var method in _paymentMethods) {
      if (method.id.toString() == selectedPaymentId) {
        return method;
      }
    }
    return null;
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
                'Upload Payment Slip',
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
          _paymentImage = File(image.path);
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
          _paymentImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _submitEnrollment() async {
    if (selectedPaymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_paymentImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload payment slip'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final sessionService = Provider.of<SessionService>(
        context,
        listen: false,
      );
      final token = sessionService.getToken();

      final Uri uri = Uri.parse("${Constant.API_URL}/training/addstudenttraining");
      // Validate training IDs before sending
      if ((trainingProgramId == null || trainingProgramId == 0) || (trainingLevelId == null || trainingLevelId == 0)) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid training program or level selected'), backgroundColor: Colors.red),
        );
        print('Enrollment aborted: trainingProgramId=$trainingProgramId, trainingLevelId=$trainingLevelId');
        return;
      }
      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add form data fields
      request.fields['name'] = fullname;
      request.fields['gender'] = gender.toLowerCase();
      request.fields['phone'] = phone;
      request.fields['email'] = email;
      request.fields['age'] = age;
      request.fields['address'] = address;
      request.fields['training_program_id'] = trainingProgramId!.toString();
      request.fields['training_level_id'] = trainingLevelId!.toString();
      request.fields['payment_id'] = selectedPaymentId!;

      // Debug: print assembled fields to console to aid server-side debugging
      print('Submitting enrollment with fields: ');
      request.fields.forEach((k, v) => print('  $k: $v'));

      // Add payment image
      request.files.add(
        await http.MultipartFile.fromPath('payment_image', _paymentImage!.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() {
        _isProcessing = false;
      });

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => classesSlip(
                enrollmentData: widget.enrollmentData,
                paymentMethod: selectedPaymentMethod?.paymentMethod ?? "N/A",
                transactionNumber: input.text.trim(),
                responseData: responseData,
              ),
            ),
          );
        }
      } else {
        String errorMessage = 'Failed to submit enrollment';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
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
          content: Text('Network Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              const SizedBox(height: 5),
              _section("Registration Information"),
              const SizedBox(height: 5),
              _information("Name", fullname),
              const SizedBox(height: 1),
              _information("Gender", gender),
              const SizedBox(height: 1),
              _information("Age", age),
              const SizedBox(height: 1),
              _information("Address", address),
              const SizedBox(height: 1),
              _information("Phone Number", phone),
              const SizedBox(height: 1),
              _information("Email", email),
              const SizedBox(height: 1),
              _information("Training Program", trainingTitle),
              const SizedBox(height: 1),
              _information("Training Level", trainingLevel),
              const SizedBox(height: 1),
              _information("Training Schedule", trainingSchedule),
              const SizedBox(height: 1),
              _information("Price", "$price Ks/month"),
              const SizedBox(height: 10),
              _section("Select Payment Method"),
              const SizedBox(height: 5),
              _paymentMethod(),
              const SizedBox(height: 5),
              _paymentInfo(),
              // const SizedBox(height: 10),
              // _input("Enter transaction number"),
              const SizedBox(height: 10),
              _imageUploadSection(),
              const SizedBox(height: 20),
              _confirm(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
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
                "Payment Slip:",
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
        if (_paymentImage != null)
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
                    _paymentImage!,
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
                          _paymentImage = null;
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
          fontWeight: FontWeight.w500,
          fontFamily: 'Custom',
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _information(String left, String right) {
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: const TextStyle(
              color: Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              right,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color.fromARGB(255, 13, 27, 42),
                fontWeight: FontWeight.w500,
                fontFamily: 'Custom',
                fontSize: 15,
              ),
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

    if (_paymentsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                _paymentsError!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadPaymentMethods,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_paymentMethods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No payment methods available'),
        ),
      );
    }

    return Container(
      child: Column(
        children: _paymentMethods.map((method) {
          bool isSelected = selectedPaymentId == method.id.toString();
          return ListTile(
            title: Text(
              method.paymentMethod,
              style: const TextStyle(
                fontFamily: 'Custom',
                color: Color.fromARGB(255, 13, 27, 42),
              ),
            ),
            leading: Radio(
              value: method.id.toString(),
              groupValue: selectedPaymentId,
              onChanged: (value) {
                setState(() {
                  selectedPaymentId = value.toString();
                  input.clear();
                });
              },
            ),
            trailing: method.paymentImageUrl.isNotEmpty
                ? Image.network(
                    method.paymentImageUrl,
                    height: 30,
                    width: 30,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.payment, size: 30);
                    },
                  )
                : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _paymentInfo() {
    final method = selectedPaymentMethod;
    
    if (method == null) {
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
          if (method.paymentImageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Image.network(
                method.paymentImageUrl,
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
                method.paymentName,
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
                method.paymentNumber,
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

  Widget _input(String text) {
    return Center(
      child: Container(
        height: 50,
        width: 300,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: TextFormField(
          controller: input,
          style: const TextStyle(
            fontFamily: "Custom",
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          decoration: InputDecoration(
            hintText: text,
            filled: true,
            fillColor: const Color.fromARGB(255, 13, 27, 42),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
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
        onPressed: _isProcessing ? null : _submitEnrollment,
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
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}