import 'package:flutter/material.dart';
import 'package:nyxproject/features/tournament/presentation/pages/tournamentEnroll.dart';

class TournamentDetailsPage extends StatelessWidget {
  const TournamentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // 1. Top Image Banner with Back Button
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Badminton Tournament',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: AssetImage("assets/images/badminton_court.jpg"),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Tournament Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Cards (Date, Entry Fee, Prize Pool)
                  Row(
                    children: [
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Date',
                        subtitle: 'Oct 15, 2026',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      _buildInfoCard(
                        icon: Icons.emoji_events,
                        title: 'Prize Pool',
                        subtitle: '\$5,000',
                        color: Colors.amber[800]!,
                      ),
                      const SizedBox(width: 10),
                      _buildInfoCard(
                        icon: Icons.confirmation_number,
                        title: 'Entry Fee',
                        subtitle: 'Free',
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Overview Section
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to the Badminton Championship 2026! Compete with top players across the region and claim your victory. Registration is open to all skill levels. Make sure to read the rules before joining.',
                    style: TextStyle(color: Colors.grey[700], height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Location & Format Info
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.location_on,
                            title: 'Location / Platform',
                            value: 'NYX Court',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.people,
                            title: 'Slots',
                            value: '32 / 64 Player Registered',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rules & Regulations
                  const Text(
                    'Rules & Regulations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildRuleItem(
                    '1. All players must check in 30 minutes before match time.',
                  ),
                  _buildRuleItem(
                    '2. Unsportsmanlike conduct will result in immediate disqualification.',
                  ),
                  _buildRuleItem('3. Cheating are strictly prohibited.'),
                  _buildRuleItem(
                    '4. Decision of tournament referees is final.',
                  ),
                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Join / Enroll Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TournamentEnrollmentForm(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ENROLL NOW',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Info Cards
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Detail Rows
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Widget for Rules List
  Widget _buildRuleItem(String ruleText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ruleText,
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
