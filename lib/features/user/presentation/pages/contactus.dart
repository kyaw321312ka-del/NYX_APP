import 'package:flutter/material.dart';
import 'package:nyxproject/features/user/data/datasources/ContactusApi.dart';
import 'package:nyxproject/features/user/data/models/Contactus.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  double get screenWidth => MediaQuery.of(context).size.width;
  
  bool _isLoading = true;
  String? _errorMessage;
  ContactUsData? _contactData;

  @override
  void initState() {
    super.initState();
    _fetchContactInfo();
  }

  Future<void> _fetchContactInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ContactusApi.getGeneralInfo();
      
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _contactData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load contact information';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
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
              const SizedBox(height: 10),
              
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchContactInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_contactData != null)
                Column(
                  children: [
                    // Shop Logo
                    if (_contactData!.logoImageUrl != null && _contactData!.logoImageUrl!.isNotEmpty)
                      _buildShopLogo(),
                    
                    // Shop Name
                    if (_contactData!.shopName != null && _contactData!.shopName!.isNotEmpty)
                      _buildShopName(),
                    
                    const SizedBox(height: 10),
                    
                    // Contact Items (NOT TAPPABLE)
                    if (_contactData!.contactInfo != null && _contactData!.contactInfo!.isNotEmpty)
                      _menuItem(
                        Icons.call_sharp,
                        _contactData!.contactInfo!,
                      ),
                    
                    if (_contactData!.address != null && _contactData!.address!.isNotEmpty)
                      _menuItem(
                        Icons.location_on,
                        _contactData!.address!,
                      ),
                    
                    if (_contactData!.socialLink != null && _contactData!.socialLink!.isNotEmpty)
                      _menuItem(
                        Icons.language,
                        _contactData!.socialLink!,
                      ),
                    
                    // Email (static)
                    _menuItem(
                      Icons.mail,
                      "Shopping@nyx.com",
                    ),
                  ],
                ),
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
              "Contact Us",
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

  Widget _buildShopLogo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(60),
            image: DecorationImage(
              image: NetworkImage(_contactData!.logoImageUrl!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Text(
          _contactData!.shopName!,
          style: const TextStyle(
            fontFamily: "Custom",
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 13, 27, 42),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 13, 27, 42),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Custom',
              color: Colors.white,
            ),
          ),
          // Removed the trailing arrow icon since it's not tappable
        ),
      ),
    );
  }
}