import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class tournamentSchedule extends StatefulWidget {
  const tournamentSchedule({super.key});

  @override
  State<tournamentSchedule> createState() => _tournamentScheduleState();
}

class _tournamentScheduleState extends State<tournamentSchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 5,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(color: Color.fromARGB(255, 13, 27, 42)),
              child: Row(
                spacing: 10,
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Schedules",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(child: Text("")),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: FaIcon(
                  //     FontAwesomeIcons.sliders,
                  //     size: 20,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  PopupMenuButton(
                    icon: FaIcon(
                      FontAwesomeIcons.sliders,
                      size: 20,
                      color: Colors.white,
                    ),

                    // Dropdown menu နှိပ်လိုက်တဲ့အခါ လုပ်ဆောင်ရမယ့် function
                    onSelected: (String value) {
                      if (value == 'option1') {
                        // Option 1 နှိပ်ရင် လုပ်ဆောင်ရမယ့် Code
                      } else if (value == 'option2') {
                        // Option 2 နှိပ်ရင် လုပ်ဆောင်ရမယ့် Code
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(value: 'option1', child: Text('All')),
                      const PopupMenuItem(
                        value: 'option2',
                        child: Text('My Match'),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            _Match("Ko Ko", "Su Su", "1:00 PM"),
            _Match("Su Su", "Mg Mg", "2:00 PM"),
            _Match("Mg Mg", "Ko Ko", "3:00 PM"),
          ],
        ),
      ),
    );
  }

  _Match(String Player1, String Player2, String Time) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.98,
      height: height * 0.095,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, style: BorderStyle.solid),
      ),
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text("Monday"), Text(Time)],
          ),
          VerticalDivider(width: 30),
          Expanded(
            child: Center(
              child: Text(
                Player1,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Text("VS"),
          Expanded(
            child: Center(
              child: Text(
                Player2,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
