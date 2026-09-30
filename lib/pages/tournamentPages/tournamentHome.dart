import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nyxproject/pages/tournamentPages/tournamentDetail.dart';
import 'package:nyxproject/pages/tournamentPages/tournamentEnroll.dart';

class tournamentHome extends StatefulWidget {
  const tournamentHome({super.key});

  @override
  State<tournamentHome> createState() => _tournamentHomeState();
}

class _tournamentHomeState extends State<tournamentHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(color: Color.fromARGB(255, 13, 27, 42)),
              child: Row(
                spacing: 10,
                children: [
                  SizedBox(width: 10),
                  FaIcon(
                    FontAwesomeIcons.trophy,
                    color: Colors.amber,
                    size: 28,
                  ),
                  Text(
                    "Tournament",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            _tornamentCard("Badminton Solo Tournament"),
            _tornamentCard("Badminton Team Tournament"),
          ],
        ),
      ),
    );
  }

  _tornamentCard(String title) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      // padding: EdgeInsets.only(bottom: 50),
      width: width * 0.98,
      height: height * 0.3,
      decoration: BoxDecoration(
        // color: Colors.amber,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TournamentDetailsPage(),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image(
                width: width * 0.98,
                height: height * 0.25,
                image: AssetImage("assets/images/badminton_court.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 10,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 50,
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Oct 1 - Oct 7",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 50,
            child: Row(
              children: [
                Icon(Icons.dehaze_outlined, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(width * 0.98, height * 0.04),
                backgroundColor: const Color.fromARGB(255, 5, 34, 59),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TournamentEnrollmentForm(),
                  ),
                );
              },
              child: Text("Enroll Now"),
            ),
          ),
        ],
      ),
    );
  }
}
