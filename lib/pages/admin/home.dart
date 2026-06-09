import 'package:flutter/material.dart';
import 'package:mustaphaprojects/add.dart';
import 'package:mustaphaprojects/pages/admin/view%20booking.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  final Color _primary = const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: _primary,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Welcome Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primary.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin 👋",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Manage your store easily from here",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ── Grid Sections ──
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [

                  _buildCard(
                    title: "Add Product",
                    icon: Icons.add_box_outlined,
                    color: Colors.green,
                    onTap: () {
                      // TODO: Navigate to Add Product page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddProjectPage(),
                        ),
                      );
                    },
                  ),

                  _buildCard(
                    title: "View Bookings",
                    icon: Icons.inventory_2_outlined,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminViewBookings(),
                        ),
                      );
                    },
                  ),

                  _buildCard(
                    title: "Analytics",
                    icon: Icons.bar_chart_outlined,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DummyPage(title: "Analytics"),
                        ),
                      );
                    },
                  ),

                  _buildCard(
                    title: "Orders",
                    icon: Icons.shopping_cart_outlined,
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DummyPage(title: "Orders"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dashboard Card ──
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Temporary Pages (Replace later) ──
class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "$title Page",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}