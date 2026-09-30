import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nyxproject/features/user/data/datasources/ForgetPasswordApi.dart';

class ForgetPassword extends StatefulWidget {
  final String email;
  
  const ForgetPassword({
    super.key,
    required this.email,
  });

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // State variables
  bool _isLoading = false;
  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  String? _tempToken; // Token from forgetpassword API
  String? _resetToken; // Token from verifyforgetpassword API
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if provided
    if (widget.email.isNotEmpty) {
      emailController.text = widget.email;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildIcon(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 12),
              _buildSubtitle(),
              const SizedBox(height: 32),
              _buildCurrentStepContent(),
              const SizedBox(height: 40),
              _buildActionButton(),
              if (_currentStep == 1) ...[
                const SizedBox(height: 20),
                _buildResendButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _currentStep == 0 ? 'Forgot Password' : 
            _currentStep == 1 ? 'Verify OTP' : 'Reset Password',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;
    
    if (_currentStep == 0) {
      iconData = Icons.lock_outline_rounded;
      iconColor = Colors.red.shade400;
    } else if (_currentStep == 1) {
      iconData = Icons.mark_email_read_outlined;
      iconColor = Colors.red.shade400;
    } else {
      iconData = Icons.password_rounded;
      iconColor = Colors.red.shade400;
    }
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 44,
        color: iconColor,
      ),
    );
  }

  Widget _buildTitle() {
    String title;
    if (_currentStep == 0) {
      title = 'Forgot Password?';
    } else if (_currentStep == 1) {
      title = 'Check your email';
    } else {
      title = 'Create new password';
    }
    
    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    String subtitle;
    if (_currentStep == 0) {
      subtitle = 'Enter your email address to receive a verification code';
    } else if (_currentStep == 1) {
      subtitle = 'We\'ve sent a 6-digit verification code to';
    } else {
      subtitle = 'Enter your new password below';
    }
    
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCurrentStepContent() {
    if (_currentStep == 0) {
      return _buildEmailInput();
    } else if (_currentStep == 1) {
      return _buildOtpInput();
    } else {
      return _buildPasswordInput();
    }
  }

  Widget _buildEmailInput() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: emailController,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade600),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      children: [
        _buildEmailDisplay(),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: otpController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
                color: Colors.grey.shade400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.email_outlined, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(
            emailController.text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: newPasswordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'New password (minimum 6 characters)',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Confirm new password',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    String buttonText;
    if (_currentStep == 0) {
      buttonText = 'Send Verification Code';
    } else if (_currentStep == 1) {
      buttonText = 'Verify & Continue';
    } else {
      buttonText = 'Reset Password';
    }
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _handleAction,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResendButton() {
    return Center(
      child: TextButton(
        onPressed: _resendCooldown > 0 ? null : _resendOTP,
        style: TextButton.styleFrom(
          foregroundColor: _resendCooldown > 0 ? Colors.grey.shade400 : Colors.red.shade400,
        ),
        child: Text(
          _resendCooldown > 0
              ? 'Resend code in ${_resendCooldown}s'
              : 'Resend verification code',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction() async {
    if (_currentStep == 0) {
      await _sendVerificationCode();
    } else if (_currentStep == 1) {
      await _verifyOtp();
    } else {
      await _resetPassword();
    }
  }

  Future<void> _sendVerificationCode() async {
    final String email = emailController.text.trim();
    
    if (email.isEmpty) {
      _showSnackBar('Please enter your email', Colors.red);
      return;
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      _showSnackBar('Please enter a valid email address', Colors.red);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await Forgetpasswordapi.forgetPassword(email: email);
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        _tempToken = result['tempToken'];
        setState(() {
          _currentStep = 1;
          _isLoading = false;
        });
        _showSnackBar(result['message'] ?? 'Verification code sent to your email', Colors.green);
        _startResendCooldown();
      } else {
        _showSnackBar(result['message'] ?? 'Failed to send code', Colors.red);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final String otp = otpController.text.trim();
    
    if (otp.isEmpty || otp.length != 6) {
      _showSnackBar('Please enter a valid 6-digit code', Colors.red);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await Forgetpasswordapi.verifyForgetPassword(
        tempToken: _tempToken!,
        otp: otp,
      );
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        _resetToken = result['resetToken'];
        setState(() {
          _currentStep = 2;
          _isLoading = false;
        });
        _showSnackBar('OTP verified! Please set your new password', Colors.green);
      } else {
        _showSnackBar(result['message'] ?? 'Invalid OTP', Colors.red);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final String newPassword = newPasswordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();
    
    if (newPassword.isEmpty || newPassword.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }
    
    if (newPassword != confirmPassword) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await Forgetpasswordapi.verifyUpdatePassword(
        tempToken: _resetToken!,
        changePassword: newPassword,
        email: emailController.text.trim(),
      );
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        _showSnackBar('Password reset successfully!', Colors.green);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showSnackBar(result['message'] ?? 'Failed to reset password', Colors.red);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await Forgetpasswordapi.forgetPassword(email: emailController.text.trim());
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        _tempToken = result['tempToken'];
        _showSnackBar('Verification code resent!', Colors.green);
        _startResendCooldown();
      } else {
        _showSnackBar(result['message'] ?? 'Failed to resend code', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });
    
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}