import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class tournamentRank extends StatefulWidget {
  const tournamentRank({super.key});

  @override
  State<tournamentRank> createState() => _tournamentRankState();
}

class _tournamentRankState extends State<tournamentRank> {
  void _showPlayerInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ), // Card ဒောင့်ဝိုင်းလေးပြုလုပ်ရန်
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 320, // Card အကျယ်
            child: Column(
              mainAxisSize: MainAxisSize.min, // Content ရှိသလောက်ပဲ အမြင့်ယူရန်
              children: [
                // ၁။ Player ၏ ဓာတ်ပုံ သို့မဟုတ် Avatar
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150', // Player ပုံ URL ထည့်ပါ
                  ),
                ),
                const SizedBox(height: 12),

                // ၂။ Player Name & Position
                const Text(
                  "Name",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level • Intermediate',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                const Divider(),

                // ၃။ Stats/Info များ (Matches, Goals, Assists)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Matches', '10'),
                      _buildStatColumn('Win', '9'),
                      _buildStatColumn('Percentage', '90%'),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Stats လေးတွေကို ခွင့်ထုတ်ပြီး ပြန်သုံးရန် Helper Function
  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

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
                  FaIcon(
                    FontAwesomeIcons.rankingStar,
                    color: Colors.amber,
                    size: 28,
                  ),
                  Text(
                    "Ranking",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                _showPlayerInfoDialog(context);
              },
              child: _Card("1", "Ko Ko", "Match Win : 95 %"),
            ),
            GestureDetector(
              onTap: () {
                _showPlayerInfoDialog(context);
              },
              child: _Card("2", "Su Su", "Match Win : 93 %"),
            ),
            GestureDetector(
              onTap: () {
                _showPlayerInfoDialog(context);
              },
              child: _Card("3", "Ma Ma", "Match Win : 90 %"),
            ),
          ],
        ),
      ),
    );
  }

  _Card(String No, String Name, String Match) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.98,
      height: height * 0.095,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 15, 11, 70),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Text(
            No,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(120),
            child: Image(
              width: width * 0.2,
              height: height * 0.08,
              image: AssetImage("assets/images/golf.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                Name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                Match,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
