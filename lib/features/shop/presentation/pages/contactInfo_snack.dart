import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/shop_payment.dart';

class contactInfoSnack extends StatefulWidget {
  const contactInfoSnack({super.key});

  @override
  State<contactInfoSnack> createState() => _contactInfoSnackState();
}

class _contactInfoSnackState extends State<contactInfoSnack> {

  final TextEditingController input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(height: 20),
              _section("Contact Informations"),
              SizedBox(height: 20),
              _section1("Fullname"),
              SizedBox(height: 5),
              _input("Enter your name"),
              SizedBox(height: 15),
              _section1("Phone Number"),
              SizedBox(height: 5),
              _input("09 xxx xxx xxx"),
              SizedBox(height: 15),
              _section1("Court Number"),
              SizedBox(height: 5),
              _input("Court - *"),
              SizedBox(height: 15),
              _section1("Remark"),
              SizedBox(height: 5),
              _input(""),
              SizedBox(height: 15),
              _continue(),
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
            child: Text(
              "Information",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(title,
         style: const TextStyle(
          color: Color.fromARGB(255, 13, 27, 42), 
          fontWeight: FontWeight.w700,
          fontFamily: 'Custom',
          fontSize: 22
          )
        ),
      ),
    );
  }

  Widget _section1(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(title,
       style: const TextStyle(
        color: Color.fromARGB(255, 13, 27, 42), 
        fontWeight: FontWeight.w500,
        fontFamily: 'Custom',
        fontSize: 15,
        )
      ),
    );
  }

  Widget _input(String text){
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: TextFormField(
        controller: input,
        style: TextStyle(
          fontFamily: "Custom",
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        decoration: InputDecoration(
          hintText: text,
          filled: true,
          fillColor: Color.fromARGB(255, 13, 27, 42),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15)
          ),
        ),
      )
    );
  }

  Widget _continue(){
    return Center(
      child: ElevatedButton.icon(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Payment()),
          );
        }, 
        label: Text(
          "Continue",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Custom",
            fontSize: 15,
          ),
        ),
        icon: Icon(Icons.arrow_right_alt_sharp,color: Colors.white,),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
      ),
    );
  }

}