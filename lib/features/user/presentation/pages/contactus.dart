import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/features/user/domain/entities/user_operations.dart';
import 'package:nyxproject/features/user/presentation/bloc/user_flow_cubit.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  double get screenWidth => MediaQuery.of(context).size.width;

  late final UserFlowCubit _userFlowCubit;

  @override
  void initState() {
    super.initState();
    _userFlowCubit = UserFlowCubit.withoutSession();
    _fetchContactInfo();
  }

  @override
  void dispose() {
    _userFlowCubit.close();
    super.dispose();
  }

  Future<void> _fetchContactInfo() async {
    try {
      await _userFlowCubit.loadContactInformation();
    } on Object {
      // The failure is represented by UserFlowState and rendered below.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchContactInfo,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 10),

                BlocBuilder<UserFlowCubit, UserFlowState>(
                  bloc: _userFlowCubit,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state.status == UserOperationStatus.failure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Column(
                            children: [
                              Text(
                                state.message ??
                                    'Failed to load contact information',
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
                      );
                    }
                    final contact = state.contactInformation;
                    if (contact == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        if (contact.logoImageUrl?.isNotEmpty == true)
                          _buildShopLogo(contact),
                        if (contact.shopName?.isNotEmpty == true)
                          _buildShopName(contact),
                        const SizedBox(height: 10),
                        if (contact.contactInfo?.isNotEmpty == true)
                          _menuItem(Icons.call_sharp, contact.contactInfo!),
                        if (contact.address?.isNotEmpty == true)
                          _menuItem(Icons.location_on, contact.address!),
                        if (contact.socialLink?.isNotEmpty == true)
                          _menuItem(Icons.language, contact.socialLink!),
                        _menuItem(Icons.mail, "Shopping@nyx.com"),
                      ],
                    );
                  },
                ),
              ],
            ),
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

  Widget _buildShopLogo(ContactInformation contact) {
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
              image: NetworkImage(contact.logoImageUrl!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopName(ContactInformation contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Text(
          contact.shopName!,
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
            style: const TextStyle(fontFamily: 'Custom', color: Colors.white),
          ),
          // Removed the trailing arrow icon since it's not tappable
        ),
      ),
    );
  }
}
