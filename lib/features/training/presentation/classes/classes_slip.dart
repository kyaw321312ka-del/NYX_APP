import 'package:flutter/material.dart';
import 'package:nyxproject/features/dashboard/presentation/main_dashboard.dart';
import 'package:nyxproject/features/cart/domain/cart_service.dart';
import 'package:nyxproject/core/storage/session_manager.dart';
import 'package:provider/provider.dart';

class classesSlip extends StatefulWidget {
  final Map<String, dynamic>? enrollmentData;
  final String? paymentMethod;
  final String? transactionNumber;
  final Map<String, dynamic>? responseData;

  const classesSlip({
    super.key,
    this.enrollmentData,
    this.paymentMethod,
    this.transactionNumber,
    this.responseData,
  });

  @override
  State<classesSlip> createState() => _classesSlipState();
}

class _classesSlipState extends State<classesSlip> {
  String orderNo = "#" + DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13);
  String date = DateTime.now().day.toString().padLeft(2, '0') + "/" +
      DateTime.now().month.toString().padLeft(2, '0') + "/" +
      DateTime.now().year.toString();
  String time = DateTime.now().hour.toString().padLeft(2, '0') + ":" +
      DateTime.now().minute.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final enrollmentData = widget.enrollmentData ?? {};
    final paymentMethod = widget.paymentMethod ?? "N/A";
    final transactionNumber = widget.transactionNumber ?? "N/A";
    final responseData = widget.responseData ?? {};
    
    // Extract data from response
    final studentInfo = responseData['data']?['studentInfo'] ?? {};
    final responseDate = studentInfo['Data'] ?? date;
    final responseTime = studentInfo['Time'] ?? time;
    final studentName = studentInfo['name'] ?? enrollmentData['fullname'] ?? "Student";
    
    // Extract enrollment details
    String fullname = enrollmentData['fullname'] ?? "N/A";
    String gender = enrollmentData['gender'] ?? "N/A";
    String age = enrollmentData['age']?.toString() ?? "N/A";
    String phone = enrollmentData['phone'] ?? "N/A";
    String email = enrollmentData['email'] ?? "N/A";
    String address = enrollmentData['address'] ?? "N/A";
    String trainingTitle = enrollmentData['trainingTitle'] ?? "Training Program";
    String trainingLevel = enrollmentData['levelName'] ?? "Beginner Level";
    int price = enrollmentData['price'] ?? 0;
    String timeSlot = enrollmentData['timeSlot'] ?? "Not specified";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 15),
              _voucher(
                studentName: studentName,
                responseDate: responseDate,
                responseTime: responseTime,
                fullname: fullname,
                gender: gender,
                age: age,
                phone: phone,
                email: email,
                address: address,
                trainingTitle: trainingTitle,
                trainingLevel: trainingLevel,
                price: price,
                timeSlot: timeSlot,
                paymentMethod: paymentMethod,
                transactionNumber: transactionNumber,
              ),
              const SizedBox(height: 15),
              _buttons(),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              "Enrollment Confirmation",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _voucher({
    required String studentName,
    required String responseDate,
    required String responseTime,
    required String fullname,
    required String gender,
    required String age,
    required String phone,
    required String email,
    required String address,
    required String trainingTitle,
    required String trainingLevel,
    required int price,
    required String timeSlot,
    required String paymentMethod,
    required String transactionNumber,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "Enrollment Placed Successfully!",
              style: TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 51, 252, 57),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Center(
            child: Text(
              "Thank you for enrolling with us.",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _infoRow("Enrollment No :", orderNo),
          const SizedBox(height: 8),
          _infoRow("Date :", responseDate),
          const SizedBox(height: 8),
          _infoRow("Time :", responseTime),
          const SizedBox(height: 15),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          const Text(
            "Student Information",
            style: TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _infoRow("Name :", fullname),
          const SizedBox(height: 6),
          _infoRow("Gender :", gender),
          const SizedBox(height: 6),
          _infoRow("Age :", age),
          const SizedBox(height: 6),
          _infoRow("Phone :", phone),
          const SizedBox(height: 6),
          _infoRow("Email :", email),
          const SizedBox(height: 6),
          _infoRow("Address :", address),
          const SizedBox(height: 15),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          const Text(
            "Training Details",
            style: TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _infoRow("Program :", trainingTitle),
          const SizedBox(height: 6),
          _infoRow("Level :", trainingLevel),
          const SizedBox(height: 6),
          _infoRow("Schedule :", timeSlot),
          const SizedBox(height: 6),
          _infoRow("Price :", "$price Ks/month"),
          const SizedBox(height: 15),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          _infoRow("Payment Method :", paymentMethod),
          if (transactionNumber.isNotEmpty && transactionNumber != "N/A")
            _infoRow("Transaction No :", transactionNumber),
          const SizedBox(height: 15),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          _priceRow("Total Amount :", "${price.toStringAsFixed(0)} Ks", isBold: true),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Custom",
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: "Custom",
              color: isBold ? Colors.white : Colors.white70,
              fontSize: isBold ? 16 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: "Custom",
              color: isBold ? const Color.fromARGB(255, 51, 252, 57) : Colors.white,
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 13, 27, 42),
                iconColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.home, size: 22),
              onPressed: () {
                final sessionService = Provider.of<SessionService>(context, listen: false);
                final cartService = Provider.of<CartService>(context, listen: false);
                
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainDashboard(
                      sessionService: sessionService,
                      cartService: cartService,
                    ),
                  ),
                  (route) => false,
                );
              },
              label: const Text(
                "Home",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Custom',
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                iconColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.receipt, size: 22),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Enrollment confirmed!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              label: const Text(
                "View Receipt",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Custom',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}