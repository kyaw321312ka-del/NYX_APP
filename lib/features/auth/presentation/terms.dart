import 'package:flutter/material.dart';

class termsPage extends StatefulWidget {
  const termsPage({super.key});

  @override
  State<termsPage> createState() => _termsPageState();
}

class _termsPageState extends State<termsPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar( 
      //   title: 
      //     Text("Help Center"),
      //     titleTextStyle: 
      //       TextStyle(
      //         fontSize: 20,
      //         fontFamily: 'Custom',
      //         color: const Color(0xFF0D1B2A),
      //         fontWeight: FontWeight.w700
      //       ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(height: 10),
              _section("Terms and Conditions"),
              _menuItem("Users must provide accurate information when placing an order."),
              _menuItem("Fake or spam orders are not allowed."),
              _menuItem("All product prices and availability may change without notice."),
              _menuItem("The admin has the right to cancel orders in special cases."),
              _menuItem("Users must not copy or reuse any content from this website without permission."),
              _menuItem(" Once the order has been handed over for delivery, we will take full responsibility until the order reaches the customer."),
              Divider(),
              _section("Pravicy Policies"),
              _menuItem("We respect your privacy and protect your personal information.  "),
              _menuItem("We may collect your name, phone number, email, and delivery address."),
              _menuItem("This information is used only for order processing and delivery."),
              _menuItem("We will not share your personal information with third parties without permission."),
              _menuItem("Payment information is handled securely. If you have any questions, please contact our support team."),
              _menuItem("If you have any questions, contact our support team."),
              Divider(),
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
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: Icon(
            Icons.arrow_back_ios_new_rounded, 
            color: Colors.white,
            ),
          ),
          Expanded(
            child: const Text(
              "Terms and Policies", 
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

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(title,
       style: const TextStyle(
        color: Color.fromARGB(255, 13, 27, 42),
        fontSize: 18,
        fontFamily: 'Custom',
        fontWeight: FontWeight.w900,
        )
      ),
    );
  }

  Widget _menuItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Container(
        width: screenWidth,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 13, 27, 42),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(title, style: TextStyle(fontFamily: 'Custom',color: Colors.white, fontSize: 15)),
      ),
    );
  }
}