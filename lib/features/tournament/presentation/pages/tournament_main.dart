import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nyxproject/features/tournament/presentation/pages/tournament_schedule.dart';
import 'package:nyxproject/features/tournament/presentation/pages/tournament_home.dart';
import 'package:nyxproject/features/tournament/presentation/pages/tournament_rank.dart';

class TournamentMain extends StatefulWidget {
  const TournamentMain({super.key});

  @override
  State<TournamentMain> createState() => _TournamentMainState();
}

class _TournamentMainState extends State<TournamentMain> {
  int currentPageIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [TournamentHome(), TournamentRank(), TournamentSchedule()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // _header,
            const SizedBox(height: 1),
            Expanded(
              child: IndexedStack(index: currentPageIndex, children: _pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 13, 27, 42),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.trophy),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.rankingStar),
            label: "Ranking",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.rectangleList),
            label: "Schedules",
          ),
        ],
      ),
    );
  }
}
