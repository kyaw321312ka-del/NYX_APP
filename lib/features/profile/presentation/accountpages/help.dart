import 'package:flutter/material.dart';

class helpPage extends StatefulWidget {
  const helpPage({super.key});

  @override
  State<helpPage> createState() => _helpPageState();
}

class _helpPageState extends State<helpPage> {
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
              _mainText(),
              _menuItem(
                  Icons.shopping_cart_outlined,
                  "Get help with my orders",() {},
                ),
              _menuItem(
                  Icons.help_outline_outlined,
                  "I'm having trouble placing an order",() {},
                ),
              _menuItem(
                  Icons.favorite_border,
                  "My support requests",() {},
                ),
              _menuItem(
                  Icons.account_circle_rounded,
                  "My account",() {},
                ),
              _menuItem(
                  Icons.settings,
                  "Payment and refund",() {},
                ),
              _menuItem(
                  Icons.question_answer,
                  "FAQ",() {},
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
                "Help Center", 
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

  Widget _mainText(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How can we help?",
            style: TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 13, 27, 42),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
          ),
          const Text(
            "Note:  If you’re trying to search for anything related to your ongoing orders, navigate to ‘Get Help with My Ordrs’.",
            style: TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 13, 27, 42),
                fontSize: 15,
              ),
          ),
        ],
      ),
    );
  }

    Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 13, 27, 42),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
          title: Text(title, style: TextStyle(fontFamily: 'Custom',color: Colors.white),),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white, ),
          onTap: onTap,
        ),
      ),
    );
  }

}