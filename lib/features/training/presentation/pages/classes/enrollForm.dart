import 'package:flutter/material.dart';
import 'package:nyxproject/features/training/presentation/pages/classes/classes_payment.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:provider/provider.dart';

class enrollForm extends StatefulWidget {
  final int? trainingId;
  final String? trainingTitle;
  final int? levelId;
  final String? levelName;
  final int? price;

  const enrollForm({
    super.key,
    this.trainingId,
    this.trainingTitle,
    this.levelId,
    this.levelName,
    this.price,
  });

  @override
  State<enrollForm> createState() => _enrollFormState();
}

class _enrollFormState extends State<enrollForm> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emergencyController = TextEditingController();

  String selectedOption = "Male";
  String? course;
  String? level;
  String? time;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill course and level from passed data
    if (widget.trainingTitle != null) {
      course = widget.trainingTitle;
    }
    if (widget.levelName != null) {
      level = widget.levelName;
    }
    _checkLoginStatus();
  }

  @override
  void dispose() {
    fullnameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    ageController.dispose();
    addressController.dispose();
    emergencyController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    _isLoggedIn = sessionService.isLoggedIn() && sessionService.getToken() != null;
    
    if (_isLoggedIn) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final user = sessionService.getStoredUser();
    
    if (user != null) {
      fullnameController.text = user.name ?? '';
      phoneController.text = user.phone ?? '';
      emailController.text = user.email ?? '';
    }
  }

  void _showLoginRequiredDialog() {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Login Required",
          style: TextStyle(fontFamily: "Custom", fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Please login to continue with your enrollment.",
          style: TextStyle(fontFamily: "Custom", fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous page
            },
            child: const Text(
              "Cancel",
              style: TextStyle(fontFamily: "Custom"),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    sessionService: sessionService,
                    cartService: cartService,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              "Login Now",
              style: TextStyle(fontFamily: "Custom", color: Colors.white),
            ),
          ),
        ],
      ),
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
              _section1("Fullname"),
              const SizedBox(height: 5),
              _input("Enter your name", fullnameController),
              const SizedBox(height: 5),
              _section1("Gender"),
              const SizedBox(height: 5),
              _gender(),
              const SizedBox(height: 5),
              _section1("Phone Number"),
              const SizedBox(height: 5),
              _input("09 xxx xxx xxx", phoneController),
              const SizedBox(height: 5),
              _section1("Email Address"),
              const SizedBox(height: 5),
              _input("example@gmail.com", emailController),
              const SizedBox(height: 5),
              _section1("Age"),
              const SizedBox(height: 5),
              _input("Enter your age", ageController),
              const SizedBox(height: 5),
              _section1("Address"),
              const SizedBox(height: 5),
              _input("Enter your address", addressController),
              const SizedBox(height: 15),
              _section1("Training Details"),
              const SizedBox(height: 5),
              _displayTrainingDetails(),
              const SizedBox(height: 15),
              _confirm(),
              const SizedBox(height: 15),
              _alert(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _displayTrainingDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _infoRow("Training Program:", widget.trainingTitle ?? "Not selected"),
          const SizedBox(height: 8),
          _infoRow("Training Level:", widget.levelName ?? "Not selected"),
          const SizedBox(height: 8),
          _infoRow("Price:", widget.price != null ? "${widget.price} Ks/month" : "N/A"),
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
        Text(
          value,
          style: const TextStyle(
            fontFamily: "Custom",
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
        mainAxisAlignment: MainAxisAlignment.start,
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Enrollment Form",
              style: const TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section1(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Color.fromARGB(255, 13, 27, 42),
          fontWeight: FontWeight.w500,
          fontFamily: 'Custom',
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _input(String text, TextEditingController controller) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          fontFamily: "Custom",
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        decoration: InputDecoration(
          hintText: text,
          filled: true,
          fillColor: const Color.fromARGB(255, 13, 27, 42),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _gender() {
    return Row(
      children: [
        Radio<String>(
          value: "Male",
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value!;
            });
          },
        ),
        const Text("Male"),
        Radio<String>(
          value: "Female",
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value!;
            });
          },
        ),
        const Text("Female"),
      ],
    );
  }

  Widget _confirm() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Check if user is logged in
          final sessionService = Provider.of<SessionService>(context, listen: false);
          final isLoggedIn = sessionService.isLoggedIn() && sessionService.getToken() != null;
          
          if (!isLoggedIn) {
            _showLoginRequiredDialog();
            return;
          }
          
          // Validate required fields
          if (fullnameController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your full name'), backgroundColor: Colors.red),
            );
            return;
          }
          if (phoneController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your phone number'), backgroundColor: Colors.red),
            );
            return;
          }
          if (emailController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your email address'), backgroundColor: Colors.red),
            );
            return;
          }
          
          // Prepare enrollment data
          final enrollmentData = {
            'trainingId': widget.trainingId,
            'trainingTitle': widget.trainingTitle,
            'levelId': widget.levelId,
            'levelName': widget.levelName,
            'price': widget.price,
            'fullname': fullnameController.text,
            'gender': selectedOption,
            'phone': phoneController.text,
            'email': emailController.text,
            'age': ageController.text,
            'address': addressController.text,
            'emergencyContact': emergencyController.text,
            'timeSlot': time,
          };
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => classesPayment(
                enrollmentData: enrollmentData,
              ),
            ),
          );
        },
        label: const Text(
          "Confirm",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Custom",
            fontSize: 15,
          ),
        ),
        icon: const Icon(Icons.arrow_right_alt_sharp, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          fixedSize: const Size(150, 50),
        ),
      ),
    );
  }

  Widget _alert() {
    return Center(
      child: Text(
        "*Trainees are responsible for their own physical safety.*",
        style: TextStyle(
          fontFamily: "Custom",
          fontSize: 15,
          color: const Color.fromARGB(255, 13, 27, 42),
        ),
      ),
    );
  }
}