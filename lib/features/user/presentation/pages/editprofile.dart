import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/core/network/api_client.dart';
import 'package:nyxproject/core/utils/app_constants.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';

class EditProfile extends StatefulWidget {
  final SessionService sessionService;
  final CartService? cartService;

  const EditProfile({
    super.key, 
    required this.sessionService,
    this.cartService,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;
  String? _imageUrl;
  String? _errorMessage;
  Map<String, dynamic>? _originalUserData;
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  String? _warning;  // Add warning variable
  bool _showWarning = false;  // Add this

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  //  Show session expired dialog
  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again to continue.'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await widget.sessionService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      sessionService: widget.sessionService,
                      cartService: widget.cartService,
                    ),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  //  Check token validity
  bool _isTokenValid() {
    if (widget.sessionService.isTokenExpired()) {
      _showSessionExpiredDialog();
      return false;
    }
    final token = widget.sessionService.getToken();
    if (token == null || token.isEmpty) {
      _showSessionExpiredDialog();
      return false;
    }
    return true;
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    
    //  Check token first
    if (!_isTokenValid()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showWarning = false;
    });

    try {
      final String? token = widget.sessionService.getToken();

      if (token == null || token.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No authentication token found.\nPlease login again.';
            _isLoading = false;
          });
          _showSessionExpiredDialog();
        }
        return;
      }

      final result = await Api.getMyProfile(token: token);

      // Check for unauthorized/token expired
      if (result['unauthorized'] == true || result['success'] == false && result['message']?.contains('expired') == true) {
        await widget.sessionService.logout();
        _showSessionExpiredDialog();
        return;
      }

      if (mounted) {
        setState(() {
          if (result['success']) {
            _originalUserData = result['data'];
            _populateForm(_originalUserData!);
            _warning = result['warning'];
            _showWarning = _warning == 'true';
            _errorMessage = null;
          } else {
            _errorMessage = result['message'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _populateForm(Map<String, dynamic> userData) {
    _nameController.text = userData['name']?.toString() ?? '';
    final dob = userData['dateOfBirth'];
    _dobController.text = dob != null && dob.toString().isNotEmpty ? dob.toString() : '';
    _emailController.text = userData['email']?.toString() ?? '';
    _phoneController.text = userData['phone']?.toString() ?? '';
    _addressController.text = userData['address']?.toString() ?? '';
    _imageUrl = userData['image_url']?.toString();
  }

  Future<void> _selectDate() async {
    DateTime? initialDate;
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobController.text);
      } catch (e) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final String formattedDate = 
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected. Click Save Changes to upload.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo taken. Click Save Changes to upload.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _showImagePickerDialog() {
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
                'Change Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 28),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 28),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    //  Check token before updating
    if (!_isTokenValid()) return;
    
    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      final String? token = widget.sessionService.getToken();

      if (token == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Session expired. Please login again.';
            _isUpdating = false;
          });
          _showSessionExpiredDialog();
        }
        return;
      }

      final response = await _updateProfileWithImage(token);

      //  Check for unauthorized
      if (response['unauthorized'] == true) {
        await widget.sessionService.logout();
        _showSessionExpiredDialog();
        return;
      }

      final bool isSuccess = response['status'] == 'success' || 
                             response['status'] == 'Edit Profile';

      if (isSuccess) {
        final String? newToken = response['new_token'];
        
        if (newToken != null && newToken.isNotEmpty) {
          await widget.sessionService.saveToken(newToken);
          print(' New token saved');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          _selectedImage = null;
        });

        await _loadUserProfile();
        
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response['message'] ?? 'Update failed';
            _isUpdating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Update failed: $e';
          _isUpdating = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _updateProfileWithImage(String token) async {
    final Uri uri = Uri.parse("${Constant.API_URL}/editProfiled/update");
    
    final request = http.MultipartRequest('PUT', uri);
    
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    
    request.fields['name'] = _nameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phone'] = _phoneController.text.trim();
    request.fields['dateOfbirth'] = _dobController.text.trim();
    request.fields['address'] = _addressController.text.trim();
    
    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
    }
    
    print(" Update URL: $uri");
    print(" Fields: ${request.fields}");
    
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("Update Response Status: ${response.statusCode}");
      print("Update Response Body: ${response.body}");
      
      if (response.statusCode == 401) {
        return {'status': 'error', 'unauthorized': true, 'message': 'Session expired'};
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return {'status': 'success', 'message': 'Profile updated successfully'};
        }
        
        final responseData = jsonDecode(response.body);
        final String? tokenFromResponse = responseData['result'];
        
        return {
          'status': responseData['status'],
          'message': responseData['status'] ?? 'Profile updated',
          'new_token': tokenFromResponse,
          'data': responseData,
        };
      } else {
        return {'status': 'error', 'message': 'Update failed'};
      }
    } catch (e) {
      print("Update Profile Error: $e");
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  // Warning Banner Widget
  Widget _warningBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Warning!!!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.orange,
                  ),
                ),
               
              ],
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && !_isUpdating
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 20),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1B2A),
                        ),
                        child: const Text('Login Again'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _header(),
                    const SizedBox(height: 10),
                    _AccPhoto(),
                    const SizedBox(height: 5),
                    _edit(),
                    if (_showWarning) _warningBanner(),  // Add warning banner
                    const SizedBox(height: 10),
                    _buildTextField("Name", _nameController),
                    _buildTextField("Date of Birth", _dobController, isDate: true),
                    _buildTextField("Email", _emailController),
                    _buildTextField("Phone", _phoneController),
                    _buildTextField("Address", _addressController),
                    const SizedBox(height: 20),
                    _updateButton(),
                    const SizedBox(height: 20),
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
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              "Edit Profile",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _AccPhoto() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: _selectedImage != null
            ? ClipOval(
                child: Image.file(
                  _selectedImage!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            : _imageUrl != null && _imageUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      _imageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 60);
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 60),
      ),
    );
  }

  Widget _edit() {
    return Center(
      child: TextButton.icon(
        onPressed: _showImagePickerDialog,
        icon: const Icon(Icons.camera_alt),
        label: const Text("Change Photo"),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isDate = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: isDate,
        onTap: isDate ? _selectDate : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
        ),
      ),
    );
  }

  Widget _updateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          minimumSize: const Size(200, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isUpdating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Save Changes', style: TextStyle(fontSize: 16 , color: Colors.white)),
      ),
    );
  }
}