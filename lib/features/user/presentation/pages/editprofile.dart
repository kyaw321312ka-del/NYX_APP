import 'package:flutter/material.dart';
import 'package:nyxproject/core/presentation/widgets/cors_safe_network_image.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';
import 'package:nyxproject/features/user/presentation/bloc/user_flow_cubit.dart';

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _warning; // Add warning variable
  bool _showWarning = false; // Add this
  late final UserFlowCubit _userFlowCubit;

  @override
  void initState() {
    super.initState();
    _userFlowCubit = UserFlowCubit.forSession(widget.sessionService);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _userFlowCubit.close();
    super.dispose();
  }

  //  Show session expired dialog
  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
          'Your session has expired. Please login again to continue.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await widget.sessionService.logout();
              if (!context.mounted) return;

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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
      final result = await _userFlowCubit.loadProfile();
      if (mounted) {
        setState(() {
          _populateForm(result.user);
          _warning = result.warning;
          _showWarning = _warning == 'true';
          _errorMessage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e.toString().contains('expired') || e.toString().contains('401')) {
        await widget.sessionService.logout();
        _showSessionExpiredDialog();
      }
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException
              ? e.message
              : 'Error loading profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _populateForm(User user) {
    _nameController.text = user.name ?? '';
    _dobController.text = user.dateOfBirth ?? '';
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phone ?? '';
    _addressController.text = user.address ?? '';
    _imageUrl = user.imageUrl;
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

    if (!mounted) return;
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

      if (!mounted) return;
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
      debugPrint('Error picking image: $e');
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

      if (!mounted) return;
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
      debugPrint('Error taking picture: $e');
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
      await _userFlowCubit.updateProfile(
        user: User(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          address: _addressController.text.trim(),
        ),
        image: _selectedImage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _selectedImage = null);
      await _loadUserProfile();
      if (mounted) setState(() => _isUpdating = false);
    } catch (e) {
      if (e.toString().contains('expired') || e.toString().contains('401')) {
        await widget.sessionService.logout();
        _showSessionExpiredDialog();
      }
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : 'Update failed: $e';
          _isUpdating = false;
        });
      }
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
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade700,
            size: 24,
          ),
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
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
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
                    _accountPhoto(),
                    const SizedBox(height: 5),
                    _edit(),
                    if (_showWarning) _warningBanner(), // Add warning banner
                    const SizedBox(height: 10),
                    _buildTextField("Name", _nameController),
                    _buildTextField(
                      "Date of Birth",
                      _dobController,
                      isDate: true,
                    ),
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
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

  Widget _accountPhoto() {
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
                child: CorsSafeNetworkImage.network(
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isDate = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: isDate,
        onTap: isDate ? _selectDate : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }
}
