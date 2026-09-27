import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nyxproject/core/constants/app_constants.dart';
import 'package:nyxproject/features/cart/domain/cart_service.dart';
import 'package:nyxproject/core/storage/session_manager.dart';
import 'package:nyxproject/features/auth/presentation/login.dart';
import 'package:provider/provider.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validation
    if (currentPasswordController.text.trim().isEmpty) {
      _showSnackBar('Please enter current password', Colors.red);
      return;
    }
    
    if (newPasswordController.text.trim().isEmpty) {
      _showSnackBar('Please enter new password', Colors.red);
      return;
    }
    
    if (newPasswordController.text.length < 6) {
      _showSnackBar('New password must be at least 6 characters', Colors.red);
      return;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
      _showSnackBar('New passwords do not match', Colors.red);
      return;
    }
    
    if (currentPasswordController.text == newPasswordController.text) {
      _showSnackBar('New password must be different from current password', Colors.red);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final sessionService = Provider.of<SessionService>(context, listen: false);
      final token = sessionService.getToken();
      
      final Uri uri = Uri.parse("${Constant.API_URL}/changepassword/password");
      
      final requestBody = jsonEncode({
        'password': currentPasswordController.text.trim(),
        'changePassword': newPasswordController.text.trim(),
      });
      
      print("Change Password URL: $uri");
      print("Request Body: $requestBody");
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (!mounted) return;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          _showSnackBar('Password changed successfully! Please login again.', Colors.green);
          
          // Clear fields
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
          
          // Logout and redirect to login page
          await sessionService.logout();
          
          if (mounted) {
            final cartService = Provider.of<CartService>(context, listen: false);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(
                  sessionService: sessionService,
                  cartService: cartService,
                ),
              ),
              (route) => false,
            );
          }
        } else {
          _showSnackBar(responseData['message'] ?? 'Failed to change password', Colors.red);
        }
      } else if (response.statusCode == 401) {
        _showSnackBar('Session expired. Please login again.', Colors.red);
        final cartService = Provider.of<CartService>(context, listen: false);
        await sessionService.logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                sessionService: sessionService,
                cartService: cartService,
              ),
            ),
            (route) => false,
          );
        }
      } else {
        final responseData = jsonDecode(response.body);
        _showSnackBar(responseData['message'] ?? 'Failed to change password', Colors.red);
      }
    } catch (e) {
      print("Change Password Error: $e");
      _showSnackBar('Network error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(
            fontFamily: "Custom",
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 27, 42),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Icon and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: screenWidth * 0.12,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Password Security",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Custom",
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Update your password to keep your account secure",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: "Custom",
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Current Password
                _buildPasswordField(
                  controller: currentPasswordController,
                  label: "Current Password",
                  hint: "Enter your current password",
                  icon: Icons.lock,
                  isVisible: _isCurrentPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                    });
                  },
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                
                const SizedBox(height: 20),
                
                // New Password
                _buildPasswordField(
                  controller: newPasswordController,
                  label: "New Password",
                  hint: "Enter new password (min 6 characters)",
                  icon: Icons.lock_outline,
                  isVisible: _isNewPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                
                const SizedBox(height: 20),
                
                // Confirm New Password
                _buildPasswordField(
                  controller: confirmPasswordController,
                  label: "Confirm New Password",
                  hint: "Re-enter your new password",
                  icon: Icons.lock_outline,
                  isVisible: _isConfirmPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                
                const SizedBox(height: 16),
                
                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password Requirements:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRequirement(
                        "At least 6 characters long",
                        newPasswordController.text.length >= 6,
                      ),
                      _buildRequirement(
                        "Different from current password",
                        newPasswordController.text.isNotEmpty && 
                        currentPasswordController.text.isNotEmpty &&
                        newPasswordController.text != currentPasswordController.text,
                      ),
                      _buildRequirement(
                        "Passwords match",
                        confirmPasswordController.text.isNotEmpty &&
                        newPasswordController.text == confirmPasswordController.text,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Update Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Update Password",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: "Custom",
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Note
                Center(
                  child: Text(
                    "You will need to login again after password change",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: "Custom",
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
            fontFamily: "Custom",
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 13, 27, 42),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            style: const TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: Colors.white70, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: onVisibilityToggle,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}