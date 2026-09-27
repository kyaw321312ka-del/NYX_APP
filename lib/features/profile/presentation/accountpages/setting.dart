import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {

  double get screenWidth => MediaQuery.of(context).size.width;
  bool isVisible = false;
  bool isVisible1 = false;
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(height: 10),
              _menuItem(
                  Icons.key,
                  "Privacy and Security",() {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                ),
              _visibalSetting(),
              _menuItem(
                  Icons.language,
                  "Languages",() {
                    setState(() {
                      isVisible1 = !isVisible1;
                    });
                  },
                ),
              _visibalSetting1(),
              _menuItem1(
                  Icons.auto_stories,
                  "Auto Save E-Receipt",() {},
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
                "Setting", 
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

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 13, 27, 42),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: Color.fromARGB(255, 255, 255, 255)),
          title: Text(title, style: TextStyle(fontFamily: 'Custom',color: Colors.white),),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white, ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _menuItem1(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 13, 27, 42),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: Color.fromARGB(255, 255, 255, 255)),
          title: Text(title, style: TextStyle(fontFamily: 'Custom',color: Colors.white),),
          trailing: Switch(
            value: isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
              });
            },
            activeTrackColor: Colors.redAccent,
            activeThumbColor: Colors.white,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _visibalSetting(){
    return Column(
      children: [
        if (isVisible)
          Column(
            children: [
              _menuItem(
                Icons.password,
                "Change Password",
                () {},
              ),
              _menuItem1(
                Icons.fingerprint,
                "Fingerprint/ Face ID",
                () {},
              ),
              _menuItem(
                Icons.paste_rounded,
                "Device History",
                () {},
              ),
              Divider()
            ],
          ),
      ],
    );
  }

  Widget _visibalSetting1(){
    return Column(
      children: [
        if (isVisible1)
          Column(
            children: [
              _menuItem(
                Icons.flag,
                "Myanmar",
                () {},
              ),
              _menuItem(
                Icons.flag,
                "English",
                () {},
              ),
              _menuItem(
                Icons.flag,
                "Chinese",
                () {},
              ),
              Divider()
            ],
          ),
      ],
    );
  }
}