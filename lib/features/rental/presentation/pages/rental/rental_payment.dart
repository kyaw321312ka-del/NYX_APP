import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyxproject/core/utils/app_constants.dart';
import 'package:nyxproject/features/orders/data/datasources/PaymentApi.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/RentalBookingApi.dart';
import 'package:nyxproject/features/orders/domain/entities/Payment.dart';
import 'package:nyxproject/features/rental/domain/entities/RentalBooking.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/rental/presentation/pages/rental/rental_slip.dart';

class rentalPayment extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const rentalPayment({super.key, this.bookingData});

  @override
  State<rentalPayment> createState() => _rentalPaymentState();
}

class _rentalPaymentState extends State<rentalPayment> {
  String? selectedPaymentId;
  final TextEditingController input = TextEditingController();
  File? _transactionImage;
  bool _isProcessing = false;
  bool _isLoadingPayments = true;
  String? _paymentsError;
  final ImagePicker _picker = ImagePicker();

  List<PaymentMethod> _paymentMethods = [];

  // Booking data
  String customerName = "";
  String customerPhone = "";
  String courtName = "";
  // String courtNumber = "";
  String bookingDate = "";
  String timeSlot = "";
  String numberOfSessions = "";
  String rentalItems = "0";
  String courtFees = "0";
  String equipmentFees = "0";
  String totalAmount = "0";

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _loadBookingData();
  }

  void _loadBookingData() {
    final bookingData = widget.bookingData ?? {};
    
    // Get user info from session
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final user = sessionService.getStoredUser();
    
    setState(() {
      customerName = user?.name ?? bookingData['name'] ?? "N/A";
      customerPhone = user?.phone ?? bookingData['phone'] ?? "N/A";
      courtName = bookingData['courtName'] ?? "N/A";
      // courtNumber = bookingData['courtNumber'] ?? "N/A";
      
      // Format date
      if (bookingData['selectedDate'] != null) {
        DateTime date = bookingData['selectedDate'];
        bookingDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } else {
        bookingDate = bookingData['date'] ?? "N/A";
      }
      
      // Get time slot
      timeSlot = bookingData['timeSlot'] ?? 
                 (bookingData['selectedTimeSlot'] != null 
                     ? "${_formatTime(bookingData['selectedTimeSlot'].startTime)} - ${_formatTime(bookingData['selectedTimeSlot'].endTime)}"
                     : "N/A");
      
      numberOfSessions = bookingData['sessionCount']?.toString() ?? "1";
      
      // Calculate fees
      courtFees = "${(bookingData['sessionPrice'] ?? 0).toStringAsFixed(0)} Ks";
      
      // Calculate equipment rental fees
      int totalRentalFees = 0;
      var equipmentQuantities = bookingData['equipmentQuantities'] ?? {};
      var equipmentPrices = bookingData['equipmentPrices'] ?? {};
      
      for (var entry in equipmentQuantities.entries) {
        if (entry.value > 0) {
          String priceStr = equipmentPrices[entry.key] ?? "0";
          int price = int.tryParse(priceStr.split(' ')[0].replaceAll(',', '')) ?? 0;
          int quantity = entry.value is int ? entry.value : (entry.value as num).toInt();
          totalRentalFees += price * quantity;
        }
      }
      
      equipmentFees = "$totalRentalFees Ks";
      
      // Calculate total rental items count
      int totalCount = 0;
      for (var value in equipmentQuantities.values) {
        if (value is int) {
          totalCount += value;
        } else if (value is num) {
          totalCount += value.toInt();
        }
      }
      rentalItems = totalCount.toString();
      
      double total = (bookingData['totalCharges'] ?? 0).toDouble();
      totalAmount = "${total.toStringAsFixed(0)} Ks";
    });
  }

  String _formatTime(String time) {
    if (time.isEmpty) return "";
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    return "$hour:${parts[1]}";
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
        setState(() {
          _paymentMethods = result['data'];
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

  bool _showTransactionInput() {
    return selectedPaymentMethod != null;
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
              _section("Information"),
              const SizedBox(height: 5),
              _information("Name", customerName),
              const SizedBox(height: 1),
              _information("Phone Number", customerPhone),
              const SizedBox(height: 1),
              _information("Court", courtName),
              const SizedBox(height: 1),
              // _information("Court Number", courtNumber),
              const SizedBox(height: 1),
              _information("Date", bookingDate),
              const SizedBox(height: 1),
              _information("Time Slot", timeSlot),
              const SizedBox(height: 1),
              _information("Number of Session", numberOfSessions),
              const SizedBox(height: 1),
              _information("Rental Items", rentalItems),
              const Divider(),
              _information("Court Fees :", courtFees),
              const SizedBox(height: 1),
              _information("Equipment Rental Fees :", equipmentFees),
              const Divider(),
              _information("Total Amount", totalAmount),
              const SizedBox(height: 1),
              const Divider(),
              _information1("Total", totalAmount),
              const SizedBox(height: 10),
              _section("Select Payment Method"),
              const SizedBox(height: 5),
              _paymentMethod(),
              const SizedBox(height: 5),
              _paymentInfo(),
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
              color: Color.fromARGB(255, 13, 27, 42),
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
        onPressed: _isProcessing ? null : _submitBookingToAPI,
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

Future<void> _submitBookingToAPI() async {
  // Validate
  if (selectedPaymentId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a payment method'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_transactionImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please upload transaction slip'),
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
    final user = sessionService.getStoredUser();

    final bookingData = widget.bookingData ?? {};
    
    // Get court time slot IDs
    List<int> courtTimeSlotIds = [];
    var selectedTimeSlot = bookingData['selectedTimeSlot'];
    if (selectedTimeSlot != null && selectedTimeSlot.id != null) {
      courtTimeSlotIds = [selectedTimeSlot.id];
    }

    // Build equipment items list for API - USE equipment_id
    List<Map<String, dynamic>> items = [];
    var equipmentQuantities = bookingData['equipmentQuantities'] ?? {};
    var equipmentIds = bookingData['equipmentIds'] ?? {}; // Get equipment IDs
    
    // Try to get equipment IDs from booking data
    for (var entry in equipmentQuantities.entries) {
      if (entry.value > 0) {
        int? equipmentId = equipmentIds[entry.key];
        
        // If no ID mapping, use hardcoded mapping as fallback
        // if (equipmentId == null) {
        //   Map<String, int> hardcodedIds = {
        //     'popcorn': 1,
        //     'popcornOne': 2,
        //     'Pro Racket': 3,
        //     'Court Shoes': 4,
        //     'Shuttlecock': 5,
        //     'Jersey': 6,
        //   };
        //   equipmentId = hardcodedIds[entry.key];
        // }
        
        if (equipmentId != null) {
          items.add({
            'equipment_id': equipmentId,
            'quantity': entry.value,
          });
        } else {
          print("Warning: No equipment ID found for ${entry.key}");
        }
      }
    }

    // Format date
    String formattedDate = bookingDate;

    print("Submitting booking with:");
    print("Items: $items");
    print("Court Time Slot IDs: $courtTimeSlotIds");

    // Submit to API
    final result = await RentalBookingApi.addMobileRentalBooking(
      venueId: bookingData['venueId'] ?? '',
      courtId: bookingData['courtId'] ?? '',
      paymentId: int.parse(selectedPaymentId!),
      date: formattedDate,
      name: customerName,
      phone: customerPhone,
      remark: (bookingData['remark'] as String?)?.isNotEmpty == true ? bookingData['remark'] : '-',
      courtTimeSlotIds: courtTimeSlotIds,
      department: 'equipment',
      items: items,
      paymentImage: _transactionImage,
      token: token ?? '',
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // Parse response data
      RentalBooking? rentalBooking;
      final responseData = result['data'];
      if (responseData != null && responseData['data'] != null) {
        final dataList = responseData['data'];
        if (dataList is List && dataList.isNotEmpty) {
          rentalBooking = RentalBooking.fromJson(dataList[0]);
        }
      }

      // Navigate to slip page with API response
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => rentalSlip(
            bookingData: bookingData,
            paymentMethod: selectedPaymentMethod?.paymentMethod ?? "N/A",
            transactionNumber: input.text.trim(),
            rentalBooking: rentalBooking,
            courtName: courtName,
            
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Booking failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print("Error in submitBooking: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

}