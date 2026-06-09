import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Overflo extends StatefulWidget {
  const Overflo({super.key});

  @override
  State<Overflo> createState() => _OverfloState();
}

class _OverfloState extends State<Overflo> {
  int _currentCarouselIndex = 0;

  // --- Sample Data ---
  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'UI/UX Design',
      'subtitle': '24 Projects Completed',
      'icon': Icons.design_services_rounded,
      'gradient': [Color(0xFF6C63FF), Color(0xFF3D35D4)],
    },
    {
      'title': 'Mobile Development',
      'subtitle': '18 Apps Launched',
      'icon': Icons.phone_iphone_rounded,
      'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
    },
    {
      'title': 'Backend Systems',
      'subtitle': '12 APIs Built',
      'icon': Icons.storage_rounded,
      'gradient': [Color(0xFFFC4F7A), Color(0xFFF9A825)],
    },
    {
      'title': 'Cloud & DevOps',
      'subtitle': '8 Deployments',
      'icon': Icons.cloud_done_rounded,
      'gradient': [Color(0xFF2196F3), Color(0xFF00BCD4)],
    },
  ];

  final List<Map<String, String>> _stats = [
    {'label': 'Projects', 'value': '62'},
    {'label': 'Clients', 'value': '38'},
    {'label': 'Reviews', 'value': '4.9★'},
  ];

  final List<Map<String, dynamic>> _skills = [
    {'name': 'Flutter', 'level': 0.92},
    {'name': 'Figma', 'level': 0.85},
    {'name': 'Firebase', 'level': 0.78},
    {'name': 'Node.js', 'level': 0.70},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          // ── Collapsible AppBar ──


          // ── Body Content ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 28),

                const SizedBox(height: 28),

                _buildStatsRow(),
                const SizedBox(height: 28),


                const SizedBox(height: 12),
                _buildCarousel(),
                const SizedBox(height: 8),




              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Profile Header
  // ────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Avatar with online ring
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF38EF7D)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 46,
                    backgroundColor: Color(0xFF1A1A2E),
                    child: CircleAvatar(
                      radius: 43,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/300?img=12',
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38EF7D),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A1A2E), width: 2.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Alex Morgan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Senior Flutter Developer  •  UI/UX Designer',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            // Location & availability chip
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChip(Icons.location_on_rounded, 'San Francisco, CA'),
                const SizedBox(width: 10),
                _buildChip(Icons.work_outline_rounded, 'Open to work'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Stats Row
  // ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: _stats.map((s) {
            final isLast = s == _stats.last;
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: !isLast
                      ? const Border(
                      right: BorderSide(color: Color(0xFFEEEEEE), width: 1))
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      s['value']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s['label']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Section Title
  // ────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF38EF7D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Carousel
  // ────────────────────────────────────────────────
  Widget _buildCarousel() {
    return CarouselSlider.builder(
      itemCount: _carouselItems.length,
      options: CarouselOptions(
        height: 190,
        viewportFraction: 0.78,
        enlargeCenterPage: true,
        enlargeFactor: 0.22,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayCurve: Curves.easeInOutCubic,
        onPageChanged: (index, _) =>
            setState(() => _currentCarouselIndex = index),
      ),
      itemBuilder: (context, index, realIndex) {
        final item = _carouselItems[index];
        return _buildCarouselCard(item);
      },
    );
  }

  Widget _buildCarouselCard(Map<String, dynamic> item) {
    final gradients = item['gradient'] as List<Color>;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradients,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradients[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item['icon'] as IconData,
                      color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_carouselItems.length, (index) {
        final isActive = index == _currentCarouselIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? const Color(0xFF6C63FF)
                : const Color(0xFFCCCCCC),
          ),
        );
      }),
    );
  }

  // ────────────────────────────────────────────────
  //  Skills
  // ────────────────────────────────────────────────
  Widget _buildSkills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: _skills.map((skill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(skill['name'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              color: Color(0xFF1A1A2E))),
                      Text(
                        '${((skill['level'] as double) * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: skill['level'] as double,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFF0EFFF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6C63FF)),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  About
  // ────────────────────────────────────────────────
  Widget _buildAbout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Passionate full-stack developer with 6+ years of experience crafting '
              'beautiful, performant mobile & web applications. I turn complex problems '
              'into elegant solutions — with pixel-perfect UIs and solid architecture '
              'that scales.',
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF555555),
            height: 1.7,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Contact Button
  // ────────────────────────────────────────────────
  Widget _buildContactButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3D35D4)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text(
            'Get In Touch',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}