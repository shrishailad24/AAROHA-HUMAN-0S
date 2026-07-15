import 'package:flutter/material.dart';
import '../career_brain/career_portal_screen.dart';
import '../education_brain/education_portal_screen.dart';
import '../money_brain/money_portal_screen.dart';
import '../health_brain/health_portal_screen.dart';
import '../life_brain/life_portal_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Futuristic dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.blueAccent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              "AAROHA OS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.purpleAccent),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blueAccent),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Morning Greeting Banner
            _buildGreetingBanner(),
            const SizedBox(height: 24),
            
            // Live OS Stats Summary
            const Text(
              "LIVE OS INSIGHTS",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildLiveInsightsGrid(),
            const SizedBox(height: 28),

            // Five Brain Core Grid
            const Text(
              "INTELLIGENT LIFE BRAINS",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildBrainsGrid(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1E38), const Color(0xFF151528)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome back, Shash",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "\"One AI. Every Life Decision.\" All your contextual brains are synced and active.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Level 3: Explorer",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Productivity: 92%",
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveInsightsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(
            "ATS Match",
            "85%",
            Icons.trending_up,
            Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            "Remaining Budget",
            "₹45,000",
            Icons.account_balance_wallet,
            Colors.cyanAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            "Water intake",
            "1.8 L / 3L",
            Icons.local_drink,
            Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBrainsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.85,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildBrainCard(
          context,
          "Career Brain",
          "Build and grow your career with smart planning.",
          Icons.work,
          [Colors.purpleAccent, Colors.purple],
          "10 Features Live",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CareerPortalScreen(userId: "test_user")),
          ),
        ),
        _buildBrainCard(
          context,
          "Education Brain",
          "Learn smarter, solve doubts, generate tests.",
          Icons.school,
          [Colors.blueAccent, Colors.indigo],
          "8 Features Live",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EducationPortalScreen(userId: "test_user")),
          ),
        ),
        _buildBrainCard(
          context,
          "Money Brain",
          "Manage budgets, expenses, and AI advisory.",
          Icons.currency_rupee,
          [          Colors.green, Colors.teal],
          "8 Features Live",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MoneyPortalScreen(userId: "test_user")),
          ),
        ),
        _buildBrainCard(
          context,
          "Health Brain",
          "Track steps, water, sleep, emergency card.",
          Icons.favorite,
          [Colors.pinkAccent, Colors.redAccent],
          "8 Features Live",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HealthPortalScreen(userId: "test_user")),
          ),
        ),
        _buildBrainCard(
          context,
          "Life Brain",
          "Civic schemes, travel, locker, planner.",
          Icons.home,
          [Colors.amber, Colors.orange],
          "8 Features Live",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LifePortalScreen(userId: "test_user")),
          ),
        ),
      ],
    );
  }

  Widget _buildBrainCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    List<Color> gradientColors,
    String tag,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              tag,
              style: TextStyle(
                color: gradientColors[0],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}