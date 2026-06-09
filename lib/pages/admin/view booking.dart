import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ════════════════════════════════════════════════════════════════════
//  ADMIN — VIEW BOOKINGS
// ════════════════════════════════════════════════════════════════════
class AdminViewBookings extends StatefulWidget {
  const AdminViewBookings({super.key});

  @override
  State<AdminViewBookings> createState() => _AdminViewBookingsState();
}

class _AdminViewBookingsState extends State<AdminViewBookings>
    with SingleTickerProviderStateMixin {
  // ── Firebase ─────────────────────────────────────────────────────
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── State ────────────────────────────────────────────────────────
  String _selectedStatus = "All";
  String _searchQuery = "";
  final TextEditingController _searchCtrl = TextEditingController();

  // ── Theme ────────────────────────────────────────────────────────
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF1E1E2C);
  static final Color _textSecondary = Colors.grey.shade600;

  // ── Status config ─────────────────────────────────────────────────
  final List<String> _statuses = [
    "All",
    "Pending",
    "In Progress",
    "Completed",
    "Rejected",
  ];

  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "In Progress":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Pending":
        return Icons.hourglass_empty_rounded;
      case "In Progress":
        return Icons.autorenew_rounded;
      case "Completed":
        return Icons.check_circle_outline;
      case "Rejected":
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── URL launcher ──────────────────────────────────────────────────
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _showSnack("Could not open link");
    }
  }

  // ── Update status ─────────────────────────────────────────────────
  Future<void> _updateStatus(String docId, String newStatus) async {
    await _firestore
        .collection('bookings')
        .doc(docId)
        .update({'status': newStatus});
    _showSnack("Status updated to \"$newStatus\"");
  }

  // ── Delete booking ─────────────────────────────────────────────────
  Future<void> _deleteBooking(String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Booking",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            "Are you sure you want to delete the booking from \"$name\"? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('bookings').doc(docId).delete();
      _showSnack("Booking deleted.");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _accent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
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
      appBar: _buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _loadingView();
          }
          if (snap.hasError) return _errorView();
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return _emptyView("No bookings yet.");
          }

          final allDocs = snap.data!.docs;

          // ── Live stats ──
          final total = allDocs.length;
          final pending = allDocs
              .where((d) =>
          (d.data() as Map)['status'] == 'Pending')
              .length;
          final inProgress = allDocs
              .where((d) =>
          (d.data() as Map)['status'] == 'In Progress')
              .length;
          final completed = allDocs
              .where((d) =>
          (d.data() as Map)['status'] == 'Completed')
              .length;

          // ── Filter ──
          final filtered = allDocs.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final statusOk = _selectedStatus == "All" ||
                d['status'] == _selectedStatus;
            final q = _searchQuery.toLowerCase();
            final searchOk = q.isEmpty ||
                (d['name'] ?? '').toString().toLowerCase().contains(q) ||
                (d['email'] ?? '').toString().toLowerCase().contains(q) ||
                (d['service'] ?? '').toString().toLowerCase().contains(q) ||
                (d['company'] ?? '').toString().toLowerCase().contains(q);
            return statusOk && searchOk;
          }).toList();

          return CustomScrollView(
            slivers: [
              // ── Stats bar ──
              SliverToBoxAdapter(
                child: _buildStatsBar(
                    total, pending, inProgress, completed),
              ),
              // ── Search + filter ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 10),
                      _buildFilterChips(),
                    ],
                  ),
                ),
              ),
              // ── Count label ──
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    "${filtered.length} booking${filtered.length == 1 ? '' : 's'} found",
                    style: TextStyle(
                        fontSize: 12.5, color: _textSecondary),
                  ),
                ),
              ),
              // ── Cards ──
              filtered.isEmpty
                  ? SliverToBoxAdapter(
                  child: _emptyView(
                      "No bookings match your filter."))
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (_, i) {
                    final doc = filtered[i];
                    final data =
                    doc.data() as Map<String, dynamic>;
                    return _bookingCard(doc.id, data, i);
                  },
                  childCount: filtered.length,
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bookings",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("Manage project requests",
              style:
              TextStyle(fontSize: 11.5, color: Colors.white70)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_outlined,
              color: Colors.white, size: 20),
        ),
      ],
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────────
  Widget _buildStatsBar(
      int total, int pending, int inProgress, int completed) {
    final stats = [
      {"label": "Total", "value": total, "color": _accent, "icon": Icons.inbox_outlined},
      {"label": "Pending", "value": pending, "color": Colors.orange, "icon": Icons.hourglass_empty_rounded},
      {"label": "Active", "value": inProgress, "color": Colors.blue, "icon": Icons.autorenew_rounded},
      {"label": "Done", "value": completed, "color": Colors.green, "icon": Icons.check_circle_outline},
    ];

    return Container(
      color: _accent,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border:
                Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(s["icon"] as IconData,
                      color: Colors.white, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    "${s["value"]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    s["label"] as String,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10.5),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) =>
          setState(() => _searchQuery = v.trim()),
      style: const TextStyle(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        hintText: "Search by name, email, service…",
        hintStyle:
        TextStyle(color: _textSecondary, fontSize: 13.5),
        prefixIcon:
        Icon(Icons.search, color: _textSecondary, size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.close,
              color: _textSecondary, size: 18),
          onPressed: () {
            _searchCtrl.clear();
            setState(() => _searchQuery = "");
          },
        )
            : null,
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
          borderSide:
          const BorderSide(color: _accent, width: 1.5),
        ),
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statuses.map((s) {
          final active = _selectedStatus == s;
          final color = s == "All" ? _accent : _statusColor(s);
          return GestureDetector(
            onTap: () => setState(() => _selectedStatus = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: active
                        ? color
                        : Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (s != "All")
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(_statusIcon(s),
                          size: 13,
                          color: active
                              ? Colors.white
                              : _statusColor(s)),
                    ),
                  Text(
                    s,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: active
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: active
                          ? Colors.white
                          : _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Booking card ──────────────────────────────────────────────────
  Widget _bookingCard(
      String docId, Map<String, dynamic> data, int index) {
    final status = data['status'] ?? 'Pending';
    final statusColor = _statusColor(status);
    final name = data['name'] ?? 'Unknown';
    final email = data['email'] ?? '';
    final phone = data['phone'] ?? '';
    final company = data['company'] ?? '';
    final service = data['service'] ?? '';
    final timeline = data['timeline'] ?? '';
    final budget = data['budget'] ?? '';
    final description = data['description'] ?? '';
    final ts = data['createdAt'] as Timestamp?;
    final date = ts != null
        ? _formatDate(ts.toDate())
        : 'Date unknown';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
            offset: Offset(0, 20 * (1 - v)), child: child),
      ),
      child: Container(
        margin:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: statusColor.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : "?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                        if (company.isNotEmpty)
                          Text(company,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary)),
                        Text(date,
                            style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(status),
                            color: Colors.white, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Details ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info grid
                  _infoRow(
                      Icons.build_outlined, "Service", service),
                  const SizedBox(height: 8),
                  _infoRow(Icons.schedule_outlined, "Timeline",
                      timeline),
                  if (budget.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow(Icons.attach_money_outlined,
                        "Budget", budget),
                  ],
                  const SizedBox(height: 8),
                  _infoRow(Icons.email_outlined, "Email", email),
                  const SizedBox(height: 8),
                  _infoRow(
                      Icons.phone_outlined, "Phone", phone),

                  // Description
                  if (description.isNotEmpty) ...[
                    const Divider(height: 22),
                    Text(
                      "Project Description",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: _textPrimary,
                        height: 1.55,
                      ),
                    ),
                  ],

                  const Divider(height: 22),

                  // ── Quick contact row ──
                  Row(
                    children: [
                      _contactChip(
                        icon: Icons.email_outlined,
                        label: "Email",
                        color: _accent,
                        onTap: () => _launch(
                            "mailto:$email"
                                "?subject=Re%3A%20Your%20Project%20Booking"),
                      ),
                      const SizedBox(width: 8),
                      _contactChip(
                        icon: Icons.chat_outlined,
                        label: "WhatsApp",
                        color: const Color(0xFF25D366),
                        onTap: () => _launch(
                            "https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}"
                                "?text=Hi%20${Uri.encodeComponent(name)}%2C%20regarding%20your%20booking."),
                      ),
                      const SizedBox(width: 8),
                      _contactChip(
                        icon: Icons.phone_outlined,
                        label: "Call",
                        color: Colors.blue,
                        onTap: () => _launch("tel:$phone"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Status update + delete ──
                  Row(
                    children: [
                      Expanded(
                        child: _statusDropdown(docId, status),
                      ),
                      const SizedBox(width: 8),
                      // Delete button
                      GestureDetector(
                        onTap: () =>
                            _deleteBooking(docId, name),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                            Colors.red.withOpacity(0.08),
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red
                                    .withOpacity(0.3)),
                          ),
                          child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status dropdown ───────────────────────────────────────────────
  Widget _statusDropdown(String docId, String currentStatus) {
    final statuses = [
      "Pending",
      "In Progress",
      "Completed",
      "Rejected"
    ];
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(currentStatus).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color:
            _statusColor(currentStatus).withOpacity(0.35)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: _statusColor(currentStatus), size: 18),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _statusColor(currentStatus),
          ),
          items: statuses
              .map((s) => DropdownMenuItem(
            value: s,
            child: Row(
              children: [
                Icon(_statusIcon(s),
                    size: 14,
                    color: _statusColor(s)),
                const SizedBox(width: 6),
                Text(s,
                    style: TextStyle(
                        fontSize: 13,
                        color: _statusColor(s),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ))
              .toList(),
          onChanged: (newStatus) {
            if (newStatus != null &&
                newStatus != currentStatus) {
              _updateStatus(docId, newStatus);
            }
          },
        ),
      ),
    );
  }

  // ── Info row ──────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _accent),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
              fontSize: 13, color: _textSecondary),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : "—",
            style: const TextStyle(
                fontSize: 13,
                color: _textPrimary,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // ── Contact chip ──────────────────────────────────────────────────
  Widget _contactChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Date formatter ────────────────────────────────────────────────
  String _formatDate(DateTime dt) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m";
  }

  // ── Loading / error / empty states ───────────────────────────────
  Widget _loadingView() {
    return Column(
      children: [
        Container(
          height: 120,
          color: _accent,
        ),
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: _accent),
        const SizedBox(height: 16),
        Text("Loading bookings…",
            style:
            TextStyle(color: _textSecondary, fontSize: 14)),
      ],
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 60, color: Colors.red),
          const SizedBox(height: 14),
          Text("Failed to load bookings",
              style: TextStyle(
                  color: _textSecondary, fontSize: 14)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _emptyView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 52, color: _accent),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "When clients submit booking requests,\nthey will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.5, color: _textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}