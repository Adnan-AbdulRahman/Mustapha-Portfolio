import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════
//  PORTFOLIO DETAILS — Bottom Sheet
// ════════════════════════════════════════════════════════════════════

/// Call this helper to show the bottom sheet anywhere:
///   showPortfolioDetails(context, item: _portfolioItems[i], isDarkMode: _isDarkMode);
void showPortfolioDetails(
    BuildContext context, {
      required Map<String, String> item,
      required bool isDarkMode,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PortfolioDetails(item: item, isDarkMode: isDarkMode),
  );
}

class PortfolioDetails extends StatefulWidget {
  final Map<String, String> item;
  final bool isDarkMode;

  const PortfolioDetails({
    super.key,
    required this.item,
    required this.isDarkMode,
  });

  @override
  State<PortfolioDetails> createState() => _PortfolioDetailsState();
}

class _PortfolioDetailsState extends State<PortfolioDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _accent = Color(0xFF6C63FF);

  Color get _surface =>
      widget.isDarkMode ? const Color(0xFF1C2128) : Colors.white;
  Color get _bg =>
      widget.isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFF5F6FA);
  Color get _textPrimary =>
      widget.isDarkMode ? Colors.white : const Color(0xFF1E1E2C);
  Color get _textSecondary =>
      widget.isDarkMode ? Colors.white60 : Colors.grey.shade600;
  Color get _chipBg =>
      widget.isDarkMode ? const Color(0xFF2D333B) : const Color(0xFFEEEEF8);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
        );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final title = item["title"] ?? "";
    final category = item["category"] ?? "";
    final image = item["image"] ?? "";
    final description = item["description"] ??
        "A carefully crafted project that showcases modern design principles "
            "and clean code architecture. Built with performance and user experience "
            "as the top priorities.";
    final tagsRaw = item["tags"] ?? "";
    final tags = tagsRaw.isNotEmpty ? tagsRaw.split(",") : <String>[];
    final liveUrl = item["liveUrl"] ?? "";
    final githubUrl = item["githubUrl"] ?? "";

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? Colors.white24
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // ── Scrollable body ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero image ───────────────────────────────
                      _buildHeroImage(image, title, category),

                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Title ─────────────────────────────
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // ── Divider ───────────────────────────
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  _accent.withOpacity(0.6),
                                  Colors.transparent,
                                ]),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // ── About this project ────────────────
                            _buildSectionLabel("About this project"),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                                height: 1.75,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // ── Tech stack ────────────────────────
                            if (tags.isNotEmpty) ...[
                              _buildSectionLabel("Tech Stack"),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: tags
                                    .map((t) => _techChip(t.trim()))
                                    .toList(),
                              ),
                              const SizedBox(height: 26),
                            ],

                            // ── Highlights ────────────────────────
                            _buildSectionLabel("Key Highlights"),
                            const SizedBox(height: 12),
                            _buildHighlight(
                              Icons.speed_rounded,
                              "Performance Optimized",
                              "Smooth 60fps animations and efficient state management.",
                            ),
                            _buildHighlight(
                              Icons.security_rounded,
                              "Security First",
                              "Implemented best practices for data protection and auth.",
                            ),
                            _buildHighlight(
                              Icons.devices_rounded,
                              "Responsive Design",
                              "Works seamlessly across all screen sizes and platforms.",
                            ),
                            const SizedBox(height: 28),

                            // ── Action buttons ────────────────────
                            _buildActionButtons(liveUrl, githubUrl),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero image with gradient overlay ──────────────────────────────
  Widget _buildHeroImage(String image, String title, String category) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Stack(
        children: [
          // Image
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDarkMode
                        ? [
                      const Color(0xFF1C2128),
                      const Color(0xFF0D1117),
                    ]
                        : [
                      const Color(0xFFDDDDF0),
                      const Color(0xFFB2BEFF),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.image_not_supported_rounded,
                  color: widget.isDarkMode
                      ? Colors.white24
                      : Colors.grey.shade400,
                  size: 50,
                ),
              ),
            ),
          ),

          // Dark gradient at bottom of image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _surface.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          // Category badge (top-left)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Close button (top-right)
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Tech chip ─────────────────────────────────────────────────────
  Widget _techChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accent.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }

  // ── Highlight row ─────────────────────────────────────────────────
  Widget _buildHighlight(IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accent, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────
  Widget _buildActionButtons(String liveUrl, String githubUrl) {
    return Row(
      children: [
        // Primary — View Live
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (liveUrl.isNotEmpty) {
                // launch liveUrl
              }
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.open_in_new_rounded,
                      color: Colors.white, size: 17),
                  SizedBox(width: 8),
                  Text(
                    "View Live",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Secondary — GitHub
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (githubUrl.isNotEmpty) {
                // launch githubUrl
              }
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _chipBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white12
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.code_rounded, color: _textPrimary, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    "Source Code",
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}