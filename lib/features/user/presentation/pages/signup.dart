import 'package:flutter/material.dart';
import 'package:nyxproject/features/user/presentation/pages/OTP.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:nyxproject/features/user/presentation/pages/terms.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/core/network/api_client.dart';

class SignupPage extends StatefulWidget {
  final SessionService sessionService;
  final CartService? cartService;
  
  const SignupPage({super.key, required this.sessionService, this.cartService});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  
  // Password visibility toggles
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // Myanmar phone number validation function
  String? _validateMyanmarPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter phone number";
    }
    
    // Remove any spaces, dashes, or special characters
    String cleanedNumber = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Myanmar phone number patterns
    // Telenor, Ooredoo, MPT, Mytel, and other operators
    final RegExp myanmarPhoneRegex = RegExp(
      r'^(09|\+959|\+?959)[0-9]{7,9}$',
    );
    
    // Specific patterns for different operators (optional - for more strict validation)
    final RegExp mptRegex = RegExp(r'^(09|\\+959)(2[0-9]{7}|5[0-9]{7}|7[0-9]{7}|8[0-9]{7})$');
    final RegExp telenorRegex = RegExp(r'^(09|\\+959)(9[0-9]{7}|4[0-9]{7})$');
    final RegExp ooredooRegex = RegExp(r'^(09|\\+959)(6[0-9]{7}|3[0-9]{7})$');
    final RegExp mytelRegex = RegExp(r'^(09|\\+959)(1[0-9]{7}|2[0-9]{7})$');
    
    // Check if number matches any Myanmar phone pattern
    if (!myanmarPhoneRegex.hasMatch(cleanedNumber)) {
      return "Please enter a valid Myanmar phone number (e.g., 09XXXXXXXXX or 959XXXXXXXX)";
    }
    
    // Check length (Myanmar phone numbers are usually 9-11 digits including 09)
    if (cleanedNumber.startsWith('09')) {
      if (cleanedNumber.length != 10 && cleanedNumber.length != 11) {
        return "Myanmar phone number must be 10-11 digits including '09'";
      }
    } else if (cleanedNumber.startsWith('959')) {
      if (cleanedNumber.length != 11 && cleanedNumber.length != 12) {
        return "Myanmar phone number must be 11-12 digits including '959'";
      }
    }
    
    return null;
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = 
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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
    super.dispose();
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
              const SizedBox(height: 10),
              _userInput(),
              const SizedBox(height: 20),
              _footer(),
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
              "Create User",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              decoration: InputDecoration(
                hintText: "Name*",
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your name";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              decoration: InputDecoration(
                hintText: "Email*",
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter email";
                }
                if (!value.contains('@')) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: phoneController,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              decoration: InputDecoration(
                hintText: "Phone Number (09XXXXXXXXX)",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                helperText: "Example: 0971234567 or 95971234567",
                helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              keyboardType: TextInputType.phone,
              validator: _validateMyanmarPhoneNumber,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: dobController,
              readOnly: true,
              onTap: _selectDate,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Date of Birth* (YYYY-MM-DD)",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select your date of birth";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              decoration: InputDecoration(
                hintText: "Password*",
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter password";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              decoration: InputDecoration(
                hintText: "Confirm Password*",
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Confirm password";
                }
                if (value != passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(350, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _handleSignUp,
                child: const Text(
                  "SIGN UP",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 15,
                    color: Color.fromARGB(255, 13, 27, 42),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(
                          sessionService: widget.sessionService,
                          cartService: widget.cartService,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontFamily: "Custom",
                      fontSize: 15,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!formKey.currentState!.validate()) return;

    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms & Conditions")),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    String formattedDate = dobController.text.trim();

    try {
      final Map<String, dynamic> signupResult = await Api.signupUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        dateOfBirth: formattedDate,
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      if (signupResult['success'] == true) {
        final String email = emailController.text.trim();
        final String tempToken = signupResult['tempToken']?.toString() ?? '';
        final String password = passwordController.text.trim(); // Store password

        print("TempToken received: $tempToken");

        if (tempToken.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Missing verification token from server")),
          );
          return;
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP sent successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Navigate to OTP page with password for auto-login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTP(
              email: email,
              tempToken: tempToken,
              password: password, // Pass password for auto-login
              sessionService: widget.sessionService,
              cartService: widget.cartService,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(signupResult['message']?.toString() ?? "Signup failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _footer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CheckboxListTile(
          title: const Text("By registration, I have read and agree to the"),
          value: _isChecked,
          onChanged: (bool? value) {
            setState(() {
              _isChecked = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const termsPage()),
                );
              },
              child: const Text(
                "Terms & Conditions",
                style: TextStyle(
                  fontFamily: "Custom",
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ),
            const Text(" and "),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Privacy Policy",
                style: TextStyle(
                  fontFamily: "Custom",
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}