import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ════════════════════════════════════════════════════════════════════
//  BOOKING PAGE  — Hire Mustapha / Book a Project
// ════════════════════════════════════════════════════════════════════
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  // ── Firebase ────────────────────────────────────────────────────
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Form ────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  // ── State ────────────────────────────────────────────────────────
  String _selectedService = "Mobile App Development";
  String _selectedTimeline = "1 – 2 Months";
  bool _isSubmitting = false;
  bool _submitted = false;

  // ── Animation ───────────────────────────────────────────────────
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Data ─────────────────────────────────────────────────────────
  final List<String> _services = [
    "Mobile App Development",
    "UI/UX Design",
    "Cybersecurity Audit",
    "Firebase Backend Setup",
    "API Integration",
    "App Maintenance & Support",
    "Other",
  ];

  final List<String> _timelines = [
    "Less than 2 Weeks",
    "2 – 4 Weeks",
    "1 – 2 Months",
    "2 – 4 Months",
    "4+ Months",
    "Not Sure Yet",
  ];

  // ── Theme ────────────────────────────────────────────────────────
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF1E1E2C);
  static final Color _textSecondary = Colors.grey.shade600;

  // ════════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(CurvedAnimation(
            parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  //  SUBMIT BOOKING
  // ════════════════════════════════════════════════════════════════
  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await _firestore.collection('bookings').add({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'company': _companyCtrl.text.trim(),
        'service': _selectedService,
        'timeline': _selectedTimeline,
        'budget': _budgetCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnack("Submission failed. Please try again.");
    }
  }

  // ── Launch helpers ───────────────────────────────────────────────
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _showSnack("Could not open link");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _accent,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Hire Me",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _submitted ? _buildSuccessView() : _buildForm(),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  SUCCESS VIEW
  // ════════════════════════════════════════════════════════════════
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              "Booking Submitted! 🎉",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Thanks for reaching out! I'll review your request and get back to you within 24 hours.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.5, color: _textSecondary, height: 1.65),
            ),
            const SizedBox(height: 32),
            // Quick-contact row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _quickContactBtn(
                  icon: Icons.mail_outline,
                  label: "Email Me",
                  color: _accent,
                  onTap: () => _launchURL(
                      "mailto:mustapharahman0544@gmail.com"),
                ),
                const SizedBox(width: 12),
                _quickContactBtn(
                  icon: Icons.chat_outlined,
                  label: "WhatsApp",
                  color: const Color(0xFF25D366),
                  onTap: () => _launchURL(
                      "https://wa.me/233551597865"
                          "?text=Hi%20Mustapha%2C%20I%20just%20submitted%20a%20booking."),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _submitted = false;
                  _nameCtrl.clear();
                  _emailCtrl.clear();
                  _phoneCtrl.clear();
                  _companyCtrl.clear();
                  _descCtrl.clear();
                  _budgetCtrl.clear();
                  _selectedService = "Mobile App Development";
                  _selectedTimeline = "1 – 2 Months";
                });
              },
              child: const Text(
                "Submit Another Request",
                style: TextStyle(color: _accent, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickContactBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 12,
                spreadRadius: 2)
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 7),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  FORM VIEW
  // ════════════════════════════════════════════════════════════════
  Widget _buildForm() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header banner ──
                _buildHeaderBanner(),
                const SizedBox(height: 24),

                // ── Personal info ──
                _sectionLabel("Personal Information"),
                const SizedBox(height: 12),
                _field(
                  controller: _nameCtrl,
                  label: "Full Name",
                  hint: "e.g. John Doe",
                  icon: Icons.person_outline,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _emailCtrl,
                  label: "Email Address",
                  hint: "e.g. john@example.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Email is required";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _phoneCtrl,
                  label: "Phone / WhatsApp",
                  hint: "e.g. +233 55 159 7865",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? "Phone is required" : null,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _companyCtrl,
                  label: "Company / Organisation (optional)",
                  hint: "e.g. Acme Corp",
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 24),

                // ── Project info ──
                _sectionLabel("Project Details"),
                const SizedBox(height: 12),
                _dropdownField(
                  label: "Service Needed",
                  icon: Icons.build_outlined,
                  value: _selectedService,
                  items: _services,
                  onChanged: (v) =>
                      setState(() => _selectedService = v!),
                ),
                const SizedBox(height: 14),
                _dropdownField(
                  label: "Expected Timeline",
                  icon: Icons.schedule_outlined,
                  value: _selectedTimeline,
                  items: _timelines,
                  onChanged: (v) =>
                      setState(() => _selectedTimeline = v!),
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _budgetCtrl,
                  label: "Estimated Budget (optional)",
                  hint: "e.g. \$500 – \$1,000",
                  icon: Icons.attach_money_outlined,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _descCtrl,
                  label: "Project Description",
                  hint:
                  "Tell me about your project, goals, and any specific requirements…",
                  icon: Icons.description_outlined,
                  maxLines: 5,
                  validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? "Please describe your project"
                      : null,
                ),
                const SizedBox(height: 28),

                // ── Submit button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                      shadowColor: _accent.withOpacity(0.4),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_outlined, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Submit Booking Request",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Quick contact note ──
                Center(
                  child: Text(
                    "Or reach me directly:",
                    style: TextStyle(
                        fontSize: 13, color: _textSecondary),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _launchURL(
                          "mailto:mustapharahman0544@gmail.com"),
                      icon: const Icon(Icons.email_outlined,
                          size: 16, color: _accent),
                      label: const Text("Email",
                          style: TextStyle(color: _accent, fontSize: 13)),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () => _launchURL(
                          "https://wa.me/233551597865"),
                      icon: const Icon(Icons.chat_outlined,
                          size: 16, color: Color(0xFF25D366)),
                      label: const Text("WhatsApp",
                          style: TextStyle(
                              color: Color(0xFF25D366), fontSize: 13)),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () =>
                          _launchURL("tel:+233551597865"),
                      icon: const Icon(Icons.phone_outlined,
                          size: 16, color: Colors.blue),
                      label: const Text("Call",
                          style: TextStyle(
                              color: Colors.blue, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header banner ─────────────────────────────────────────────
  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rocket_launch_outlined,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Start Your Project",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Fill out the form and I'll get back to you within 24 hours.",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Quick stat chips
          Row(
            children: [
              _bannerChip(Icons.timer_outlined, "Fast Turnaround"),
              const SizedBox(width: 8),
              _bannerChip(Icons.verified_outlined, "Quality Work"),
              const SizedBox(width: 8),
              _bannerChip(Icons.lock_outline, "Secure Apps"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerChip(IconData icon, String label) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Text field ────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
        TextStyle(fontSize: 13.5, color: _textSecondary),
        hintStyle:
        TextStyle(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 20, color: _textSecondary),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // ── Dropdown field ────────────────────────────────────────────
  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: const TextStyle(
                    fontSize: 14, color: _textPrimary),
                hint: Text(label,
                    style: TextStyle(
                        color: _textSecondary, fontSize: 13.5)),
                items: items
                    .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item,
                      style:
                      const TextStyle(fontSize: 13.5)),
                ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}