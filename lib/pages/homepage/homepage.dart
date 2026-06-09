import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

import 'booking.dart';

// ═══════════════════════════════════════════════════════════════════
//  LEGSIGN CREATIVE STUDIO  ·  Portfolio Web App  [ENHANCED]
//  Dark | Cinematic | High-End Creative Agency
// ═══════════════════════════════════════════════════════════════════
//
//  ➜ Add to pubspec.yaml:
//      google_fonts: ^6.2.1
//
// ═══════════════════════════════════════════════════════════════════

// ── Color Palette ──────────────────────────────────────────────────
const Color kBg        = Color(0xFF060610);
const Color kSurface   = Color(0xFF0C0C1C);
const Color kCard      = Color(0xFF111124);
const Color kGold      = Color(0xFFC9A84C);
const Color kGoldGlow  = Color(0x22C9A84C);
const Color kGoldDim   = Color(0x55C9A84C);
const Color kWhite     = Color(0xFFFFFFFF);
const Color kOffWhite  = Color(0xFFDDDDEE);
const Color kGrey      = Color(0xFF606075);
const Color kLightGrey = Color(0xFFAAAAAC);
const Color kBorder    = Color(0xFF1E1E35);

// ══════════════════════════════════════════════════════════════════
//  ★ NEW: AURORA BACKGROUND PAINTER
//  Slowly shifting colour blobs behind particles for depth/nebula feel
// ══════════════════════════════════════════════════════════════════

class _AuroraPainter extends CustomPainter {
  final double t;
  _AuroraPainter(this.t);

  void _blob(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
}

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.sin;
    final c = math.cos;

    _blob(canvas,
        Offset(size.width * (0.15 + s(t * 0.7) * 0.09), size.height * (0.28 + c(t * 0.55) * 0.09)),
        size.width * 0.40, kGold.withOpacity(0.048));
    _blob(canvas,
        Offset(size.width * (0.78 + c(t * 0.6) * 0.08), size.height * (0.38 + s(t * 0.45) * 0.11)),
        size.width * 0.34, const Color(0xFF2A1070).withOpacity(0.065));
    _blob(canvas,
        Offset(size.width * (0.48 + s(t * 0.9) * 0.07), size.height * (0.65 + c(t * 0.8) * 0.09)),
        size.width * 0.30, kGold.withOpacity(0.030));
    _blob(canvas,
        Offset(size.width * (0.35 + c(t * 0.5) * 0.06), size.height * (0.55 + s(t * 1.1) * 0.07)),
        size.width * 0.22, const Color(0xFF400060).withOpacity(0.04));
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}

// ══════════════════════════════════════════════════════════════════
//  ★ NEW: SCANLINE OVERLAY PAINTER  (CRT cinematic effect)
// ══════════════════════════════════════════════════════════════════

class _ScanlinesPainter extends CustomPainter {
  final double offset;
  _ScanlinesPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.014);
    final gap = 5.0;
    for (double y = (offset * gap) % gap; y < size.height; y += gap) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter old) => old.offset != offset;
}

// ══════════════════════════════════════════════════════════════════
//  PARTICLE BACKGROUND  (original + enhanced glow)
// ══════════════════════════════════════════════════════════════════

class _Particle {
  Offset position;
  Offset velocity;
  double radius;
  double opacity;
  _Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.position = Offset(
        (p.position.dx + p.velocity.dx) % size.width,
        (p.position.dy + p.velocity.dy) % size.height,
      );
      if (p.position.dx < 0) p.position = Offset(size.width, p.position.dy);
      if (p.position.dy < 0) p.position = Offset(p.position.dx, size.height);

      // Outer glow
      canvas.drawCircle(
        p.position,
        p.radius * 3.5,
        Paint()..color = kGold.withOpacity(p.opacity * 0.12),
      );
      // Core
      canvas.drawCircle(
        p.position,
        p.radius,
        Paint()..color = kGold.withOpacity(p.opacity * 0.65),
      );
    }

    final linePaint = Paint()
      ..color = kGold.withOpacity(0.06)
      ..strokeWidth = 0.5;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final d = (particles[i].position - particles[j].position).distance;
        if (d < 150) {
          linePaint.color = kGold.withOpacity((1 - d / 150) * 0.07);
          canvas.drawLine(particles[i].position, particles[j].position, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ══════════════════════════════════════════════════════════════════
//  ★ NEW: GLITCH TEXT WIDGET
//  Periodically shifts cyan + red channel ghosts for cinematic glitch
// ══════════════════════════════════════════════════════════════════

class _GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool enabled;
  const _GlitchText({required this.text, required this.style, this.enabled = true});
  @override State<_GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<_GlitchText> {
  bool _glitching = false;
  double _dx1 = 0, _dy1 = 0, _dx2 = 0, _dy2 = 0;
  Timer? _schedTimer, _frameTimer;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _schedule();
  }

  void _schedule() {
    _schedTimer = Timer(
      Duration(milliseconds: 3800 + _rng.nextInt(6000)),
      _startGlitch,
    );
  }

  void _startGlitch() {
    if (!mounted) return;
    int frames = 0;
    _frameTimer = Timer.periodic(const Duration(milliseconds: 55), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _glitching = true;
        _dx1 = (_rng.nextDouble() - 0.5) * 12;
        _dy1 = (_rng.nextDouble() - 0.5) * 6;
        _dx2 = (_rng.nextDouble() - 0.5) * 9;
        _dy2 = (_rng.nextDouble() - 0.5) * 4;
      });
      if (++frames > 11) {
        t.cancel();
        if (mounted) setState(() => _glitching = false);
        _schedule();
      }
    });
  }

  @override
  void dispose() {
    _schedTimer?.cancel();
    _frameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_glitching) return Text(widget.text, style: widget.style);
    return Stack(clipBehavior: Clip.none, children: [
      // Cyan channel
      Transform.translate(
        offset: Offset(_dx1, _dy1),
        child: Text(widget.text,
            style: widget.style.copyWith(
                color: const Color(0xFF00EEFF).withOpacity(0.72),
                shadows: const [])),
      ),
      // Red channel
      Transform.translate(
        offset: Offset(-_dx2, _dy2),
        child: Text(widget.text,
            style: widget.style.copyWith(
                color: const Color(0xFFFF0055).withOpacity(0.65),
                shadows: const [])),
      ),
      // Main text
      Text(widget.text, style: widget.style),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════
//  ★ NEW: PULSING DOT (Available badge)
//  Three expanding rings that emanate outward continuously
// ══════════════════════════════════════════════════════════════════

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with TickerProviderStateMixin {
  late List<AnimationController> _cs;

  @override
  void initState() {
    super.initState();
    _cs = List.generate(3, (i) {
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
      Future.delayed(Duration(milliseconds: i * 860), () {
        if (mounted) c.repeat();
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _cs) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28, height: 28,
      child: Stack(alignment: Alignment.center, children: [
        for (final c in _cs)
          AnimatedBuilder(
            animation: c,
            builder: (_, __) => Transform.scale(
              scale: 1 + c.value * 3.0,
              child: Opacity(
                opacity: (1 - c.value).clamp(0.0, 1.0) * 0.55,
                child: Container(
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kGold, width: 1),
                  ),
                ),
              ),
            ),
          ),
        Container(
          width: 9, height: 9,
          decoration: BoxDecoration(
            color: kGold,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: kGold.withOpacity(0.8), blurRadius: 10, spreadRadius: 2),
            ],
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  ★ NEW: SHIMMER SECTION TITLE
//  Gold shimmer sweeps across Bebas Neue section headings
// ══════════════════════════════════════════════════════════════════

class _ShimmerTitle extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _ShimmerTitle({required this.text, required this.style});
  @override State<_ShimmerTitle> createState() => _ShimmerTitleState();
}

class _ShimmerTitleState extends State<_ShimmerTitle> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3800))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final pos = _ctrl.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [kWhite, kWhite, kGold, kWhite, kWhite],
            stops: [
              0.0,
              (pos - 0.28).clamp(0.0, 1.0),
              pos.clamp(0.0, 1.0),
              (pos + 0.28).clamp(0.0, 1.0),
              1.0,
            ],
          ).createShader(bounds),
          child: child!,
        );
      },
      child: Text(widget.text, style: widget.style),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  ★ NEW: ANIMATED GRADIENT BORDER CARD
//  Gold rotating gradient border for testimonials / contact sections
// ══════════════════════════════════════════════════════════════════

class _AnimatedBorderCard extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  const _AnimatedBorderCard({required this.child, this.borderWidth = 1.5});
  @override State<_AnimatedBorderCard> createState() => _AnimatedBorderCardState();
}

class _AnimatedBorderCardState extends State<_AnimatedBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => CustomPaint(
        painter: _RotatingBorderPainter(_ctrl.value, widget.borderWidth),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _RotatingBorderPainter extends CustomPainter {
  final double t;
  final double width;
  _RotatingBorderPainter(this.t, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = SweepGradient(
      startAngle: angle,
      endAngle: angle + 2 * math.pi,
      colors: [
        kGold.withOpacity(0.0),
        kGold.withOpacity(0.05),
        kGold.withOpacity(0.6),
        kGold,
        kGold.withOpacity(0.6),
        kGold.withOpacity(0.05),
        kGold.withOpacity(0.0),
      ],
      stops: const [0.0, 0.1, 0.2, 0.25, 0.3, 0.4, 1.0],
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_RotatingBorderPainter old) => old.t != t;
}

// ══════════════════════════════════════════════════════════════════
//  ★ NEW: FLOATING HERO SHAPES (geometric wireframes right-side)
// ══════════════════════════════════════════════════════════════════

class _FloatingHeroShapes extends StatelessWidget {
  final Animation<double> animation; // 0→2π repeating
  final bool mobile;
  const _FloatingHeroShapes({required this.animation, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = animation.value;
        final s = math.sin;
        final c = math.cos;

        final rOuter  = mobile ? 380.0 : 590.0;
        final rMid    = mobile ? 240.0 : 400.0;
        final rInner  = mobile ? 130.0 : 210.0;
        final rX      = mobile ? -160.0 : -50.0;
        final rY      = mobile ? 80.0 : 60.0;

        return Stack(children: [
          // ── Outermost slowly rotating ring
          Positioned(
            right: rX, top: rY,
            child: Transform.rotate(
              angle: t * 0.07,
              child: Container(
                width: rOuter, height: rOuter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGold.withOpacity(0.045), width: 1),
                ),
              ),
            ),
          ),
          // ── Medium ring (counter-rotate)
          Positioned(
            right: rX + (rOuter - rMid) / 2,
            top: rY + (rOuter - rMid) / 2,
            child: Transform.rotate(
              angle: -t * 0.12,
              child: Container(
                width: rMid, height: rMid,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGold.withOpacity(0.10), width: 1),
                ),
              ),
            ),
          ),
          // ── Inner ring (faster)
          Positioned(
            right: rX + (rOuter - rInner) / 2,
            top: rY + (rOuter - rInner) / 2,
            child: Transform.rotate(
              angle: t * 0.22,
              child: Container(
                width: rInner, height: rInner,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGold.withOpacity(0.18), width: 1),
                ),
              ),
            ),
          ),
          // ── Large square diamond (rotated 45°)
          Positioned(
            right: rX + rOuter * 0.27,
            top: rY + rOuter * 0.27,
            child: Transform.rotate(
              angle: math.pi / 4 + t * 0.09,
              child: Container(
                width: rOuter * 0.46, height: rOuter * 0.46,
                decoration: BoxDecoration(
                  border: Border.all(color: kGold.withOpacity(0.08), width: 1),
                ),
              ),
            ),
          ),
          // ── Medium rotating square
          Positioned(
            right: rX + rOuter * 0.38,
            top: rY + rOuter * 0.35,
            child: Transform.rotate(
              angle: t * 0.35,
              child: Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  border: Border.all(color: kGold.withOpacity(0.30), width: 1),
                ),
              ),
            ),
          ),
          // ── Small fast square
          Positioned(
            right: rX + rOuter * 0.44 + 20,
            top: rY + rOuter * 0.22,
            child: Transform.rotate(
              angle: -t * 0.65,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  border: Border.all(color: kGold.withOpacity(0.45), width: 1.5),
                ),
              ),
            ),
          ),
          // ── Tiny diamond
          Positioned(
            right: rX + rOuter * 0.30,
            top: rY + rOuter * 0.55,
            child: Transform.rotate(
              angle: math.pi / 4 + t * 0.5,
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  border: Border.all(color: kGold.withOpacity(0.55), width: 1),
                ),
              ),
            ),
          ),
          // ── Orbiting glowing dot (outer ring path)
          Positioned(
            right: rX + rOuter / 2 - rOuter * 0.48 * c(t * 0.4) - 4,
            top: rY + rOuter / 2 + rOuter * 0.48 * s(t * 0.4) - 4,
            child: Container(
              width: 7, height: 7,
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.80),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: kGold.withOpacity(0.7), blurRadius: 12, spreadRadius: 1)],
              ),
            ),
          ),
          // ── Orbiting dot (inner ring path, opposite direction)
          Positioned(
            right: rX + rOuter / 2 - rInner * 0.48 * c(-t * 0.65 + math.pi) - 3,
            top: rY + rOuter / 2 + rInner * 0.48 * s(-t * 0.65 + math.pi) - 3,
            child: Container(
              width: 5, height: 5,
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.55),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: kGold.withOpacity(0.5), blurRadius: 8)],
              ),
            ),
          ),
          // ── Floating cross-hair lines (vertical + horizontal faint)
          Positioned(
            right: rX + rOuter * 0.5 - 0.5,
            top: rY,
            child: Container(
              width: 1, height: rOuter,
              color: kGold.withOpacity(0.04),
            ),
          ),
          Positioned(
            right: rX,
            top: rY + rOuter * 0.5 - 0.5,
            child: Container(
              width: rOuter, height: 1,
              color: kGold.withOpacity(0.04),
            ),
          ),
        ]);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  ★ NEW: TYPEWRITER HERO SUBTITLE (kept same, now in own widget)
//  (logic unchanged, refactored for clarity)
// ══════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════
//  HOMEPAGE
// ══════════════════════════════════════════════════════════════════

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {

  // ── Hero Animations (original)
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _logoBadgeFade;

  // ── Particle Animation (original)
  late AnimationController _particleCtrl;
  late List<_Particle> _particles;

  // ── ★ NEW: Aurora animation controller
  late AnimationController _auroraCtrl;

  // ── ★ NEW: Floating shapes controller
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim; // 0 → 2π

  // ── ★ NEW: Scanlines tied to float for efficiency
  // (reuse _floatCtrl.value)

  // ── Typewriter (original)
  final String _fullText = 'Mobile App Developer & Cyber security analyst';
  String _typedText = '';
  int _typeIdx = 0;
  Timer? _typeTimer;
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  // ── Scroll (original)
  final ScrollController _scrollCtrl = ScrollController();

  // ── Section GlobalKeys (original)
  final GlobalKey _aboutKey        = GlobalKey();
  final GlobalKey _servicesKey     = GlobalKey();
  final GlobalKey _portfolioKey    = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _contactKey      = GlobalKey();

  // ── Section Visibility (original)
  bool _aboutVis    = false;
  bool _servicesVis = false;
  bool _portfolioVis = false;
  bool _testisVis   = false;
  bool _contactVis  = false;

  // ── Navbar scroll state (original)
  bool _navScrolled = false;

  // ── Portfolio filter (original)
  String _activeFilter = 'All';

  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Hero (original)
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _heroFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.25, 0.85, curve: Curves.easeOut)));
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
        CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.2, 0.9, curve: Curves.easeOut)));
    _logoBadgeFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    // Particles (original)
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _initParticles();

    // ★ Aurora (new)
    _auroraCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();

    // ★ Floating shapes (new) — drives shapes + scanlines
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 13))..repeat();
    _floatAnim = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.linear));

    // Scroll (original)
    _scrollCtrl.addListener(_onScroll);

    // Fire hero (original)
    Future.delayed(const Duration(milliseconds: 150), () => _heroCtrl.forward());

    // Typewriter (original)
    Future.delayed(const Duration(milliseconds: 1400), _startTypewriter);

    // Cursor blink (original)
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 550),
            (_) { if (mounted) setState(() => _cursorVisible = !_cursorVisible); });
  }

  void _initParticles() {
    final rng = math.Random();
    // ★ More particles (was 65, now 90)
    _particles = List.generate(90, (_) => _Particle(
      position: Offset(rng.nextDouble() * 1920, rng.nextDouble() * 1080),
      velocity: Offset((rng.nextDouble() - 0.5) * 0.38, (rng.nextDouble() - 0.5) * 0.38),
      radius: rng.nextDouble() * 2.0 + 0.4,
      opacity: rng.nextDouble() * 0.55 + 0.1,
    ));
  }

  void _startTypewriter() {
    _typeTimer = Timer.periodic(const Duration(milliseconds: 52), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_typeIdx < _fullText.length) {
        setState(() { _typedText = _fullText.substring(0, ++_typeIdx); });
      } else { t.cancel(); }
    });
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset;

    if (offset > 55 && !_navScrolled)       setState(() => _navScrolled = true);
    else if (offset <= 55 && _navScrolled)  setState(() => _navScrolled = false);

    if (!_aboutVis)     _checkVis(_aboutKey,        () => setState(() => _aboutVis = true));
    if (!_servicesVis)  _checkVis(_servicesKey,     () => setState(() => _servicesVis = true));
    if (!_portfolioVis) _checkVis(_portfolioKey,    () => setState(() => _portfolioVis = true));
    if (!_testisVis)    _checkVis(_testimonialsKey, () => setState(() => _testisVis = true));
    if (!_contactVis)   _checkVis(_contactKey,      () => setState(() => _contactVis = true));
  }

  void _checkVis(GlobalKey key, VoidCallback cb) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    if (pos.dy < MediaQuery.of(context).size.height * 0.88) cb();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 850), curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _particleCtrl.dispose();
    _auroraCtrl.dispose();
    _floatCtrl.dispose();
    _scrollCtrl.dispose();
    _typeTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mobile = size.width < 768;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // ★ 1. Aurora (behind everything)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _auroraCtrl,
              builder: (_, __) => CustomPaint(
                painter: _AuroraPainter(_auroraCtrl.value * 2 * math.pi),
              ),
            ),
          ),

          // ── 2. Particle canvas (original)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(painter: _ParticlePainter(_particles)),
            ),
          ),

          // ★ 3. Scanline overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ScanlinesPainter(_floatCtrl.value),
              ),
            ),
          ),

          // ── 4. Scrollable content (original structure)
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(children: [
              _heroSection(size, mobile),
              _aboutSection(size, mobile),
              _servicesSection(size, mobile),
              _portfolioSection(size, mobile),
              _testimonialsSection(size, mobile),
              _contactSection(size, mobile),
              _footer(size, mobile),
            ]),
          ),

          // ── 5. Sticky Navbar (original)
          Positioned(top: 0, left: 0, right: 0, child: _navbar(mobile)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  NAVBAR  (original logic, logo dot → _PulsingDot)
  // ══════════════════════════════════════════════════════════════
  Widget _navbar(bool mobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 64, vertical: _navScrolled ? 14 : 22),
      decoration: BoxDecoration(
        color: _navScrolled ? kBg.withOpacity(0.96) : Colors.transparent,
        border: _navScrolled ? Border(bottom: BorderSide(color: kBorder, width: 1)) : null,
        boxShadow: _navScrolled
            ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24)]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeTransition(
            opacity: _logoBadgeFade,
            child: Row(children: [
              // ★ Pulsing dot replaces static dot
              const _PulsingDot(),
              const SizedBox(width: 10),
              Text('MUSTAPHA', style: GoogleFonts.bebasNeue(fontSize: 20, color: kWhite, letterSpacing: 5)),
              Text('ABDUL RAHMAN', style: GoogleFonts.bebasNeue(fontSize: 20, color: kGold, letterSpacing: 5)),
            ]),
          ),
          if (!mobile) Row(children: [
            _NavLink('About',    () => _scrollTo(_aboutKey)),
            _NavLink('Services', () => _scrollTo(_servicesKey)),
            _NavLink('Works',    () => _scrollTo(_portfolioKey)),
            _NavLink('Contact',  () => _scrollTo(_contactKey)),
          ]),
          if (!mobile) _GlowButton(label: 'HIRE ME', onTap: () => _scrollTo(_contactKey), small: true),
          if (mobile) const Icon(Icons.menu, color: kWhite, size: 26),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HERO SECTION  (★ glitch title, floating shapes, animated stats)
  // ══════════════════════════════════════════════════════════════
  Widget _heroSection(Size size, bool mobile) {
    return SizedBox(
      height: size.height,
      child: Stack(children: [
        // Radial glow background (original)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.3, 0),
                radius: 1.1,
                colors: [kGold.withOpacity(0.06), Colors.transparent, kBg],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // ★ Floating geometric shapes (right side)
        _FloatingHeroShapes(animation: _floatAnim, mobile: mobile),

        // Left vertical accent line (original)
        Positioned(
          left: mobile ? 20 : 62, top: 0, bottom: 0,
          child: Container(width: 1, color: kGold.withOpacity(0.12)),
        ),

        // Right corner decoration (original)
        Positioned(
          top: 100, right: mobile ? 20 : 60,
          child: FadeTransition(
            opacity: _logoBadgeFade,
            child: Column(children: [
              Container(width: 1, height: 80, color: kGold.withOpacity(0.3)),
              const SizedBox(height: 8),
              RotatedBox(quarterTurns: 1,
                  child: Text('CREATIVE STUDIO',
                      style: GoogleFonts.dmSans(
                          fontSize: 10, color: kGold.withOpacity(0.4), letterSpacing: 4))),
            ]),
          ),
        ),

        // Main hero content
        Padding(
          padding: EdgeInsets.only(left: mobile ? 36 : 110, right: mobile ? 28 : 80, top: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ★ Available badge with pulsing dot
              FadeTransition(
                opacity: _logoBadgeFade,
                child: Container(
                  padding: const EdgeInsets.only(left: 6, right: 14, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: kGold.withOpacity(0.45)),
                    color: kGoldGlow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const _PulsingDot(),
                    const SizedBox(width: 6),
                    Text('AVAILABLE FOR PROJECTS',
                        style: GoogleFonts.dmSans(fontSize: 10, color: kGold, letterSpacing: 3.5,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(height: 30),

              // ★ Hero title with GLITCH effect
              SlideTransition(
                position: _heroSlide,
                child: FadeTransition(
                  opacity: _heroFade,
                  child: _GlitchText(
                    text: 'MUSTAPHA \n RAHMAN',
                    style: GoogleFonts.bebasNeue(
                      fontSize: mobile ? 68 : 120,
                      color: kWhite,
                      letterSpacing: 8,
                      height: 0.92,
                    ),
                  ),
                ),
              ),

              // Gold divider line (original)
              FadeTransition(
                opacity: _heroFade,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 18),
                  width: 90,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [kGold, kGold.withOpacity(0.0)]),
                  ),
                ),
              ),

              // Typewriter (original)
              SizedBox(
                height: 34,
                child: Row(children: [
                  Text(_typedText,
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: mobile ? 17 : 23, color: kLightGrey,
                          fontStyle: FontStyle.italic, letterSpacing: 1.5)),
                  if (_cursorVisible)
                    Container(width: 2, height: 20, margin: const EdgeInsets.only(left: 2, top: 2), color: kGold),
                ]),
              ),

              const SizedBox(height: 12),

              // CTA Buttons (original)
              FadeTransition(
                opacity: _heroFade,
                child: Wrap(spacing: 18, runSpacing: 16, children: [
                  _GlowButton(label: 'VIEW PORTFOLIO', onTap: () => _scrollTo(_portfolioKey)),
                  _OutlineBtn(label: 'HIRE ME',        onTap: () => _scrollTo(_contactKey)),
                ]),
              ),

              const SizedBox(height: 52),

              // ★ Animated counter stats
              FadeTransition(
                opacity: _heroFade,
                child: Wrap(spacing: 48, runSpacing: 24, children: [
                  _AnimatedStatWidget('18+', 'Projects Done'),
                  _AnimatedStatWidget('7+', 'Happy Clients'),
                  _AnimatedStatWidget('6+',  'Years Experience'),
                ]),
              ),
            ],
          ),
        ),

        // Scroll indicator (original)
        Positioned(
          bottom: 28, left: 0, right: 0,
          child: FadeTransition(
            opacity: _heroFade,
            child: Column(children: [
              Text('SCROLL',
                  style: GoogleFonts.dmSans(fontSize: 10, color: kGrey, letterSpacing: 4)),
              const SizedBox(height: 8),
              const _BouncingArrow(),
            ]),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  ABOUT SECTION  (original logic, ★ shimmer badge)
  // ══════════════════════════════════════════════════════════════
  Widget _aboutSection(Size size, bool mobile) {
    return _RevealSection(
      sectionKey: _aboutKey,
      visible: _aboutVis,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 30 : 100, vertical: 100),
        child: mobile
            ? Column(children: [_aboutImage(), const SizedBox(height: 48), _aboutText()])
            : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: _aboutImage()),
          const SizedBox(width: 80),
          Expanded(child: _aboutText()),
        ]),
      ),
    );
  }

  Widget _aboutImage() {
    return Stack(children: [
      Positioned(top: 18, left: 18, right: -18, bottom: -18,
          child: Container(decoration: BoxDecoration(
              border: Border.all(color: kGold.withOpacity(0.25))))),
      // ★ Animated border card wraps the image container
      _AnimatedBorderCard(
        borderWidth: 1,
        child: Container(
          height: 440,
          decoration: BoxDecoration(color: kCard),
          child: Stack(children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, kBg.withOpacity(0.7)]),
                ),
              ),
            ),
            Image.asset('assets/images/logo.jpg', fit: BoxFit.fill),
          ]),
        ),
      ),
    ]);
  }

  Widget _aboutText() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionBadge('ABOUT ME'),
      const SizedBox(height: 18),
      Text('Crafting Visual Stories\nThat Leave a Mark',
          style: GoogleFonts.cormorantGaramond(
              fontSize: 42, color: kWhite, fontWeight: FontWeight.w700, height: 1.1)),
      const SizedBox(height: 10),
      Container(width: 60, height: 2, color: kGold),
      const SizedBox(height: 26),
      Text(
          'I\'m passionate and creative full-stack mobile developer specializing in Flutter and Dart, '
          'I blend aesthetic sensibility with technical precision to craft beautiful, '
          'high-performance mobile applications and digital products '
          'that resonate, inspire, and deliver real results.',
          style: GoogleFonts.dmSans(fontSize: 15, color: kLightGrey, height: 1.85)),
      const SizedBox(height: 14),
      Text(
          'From brand identity to Flutter mobile apps — I cover the full spectrum of visual communication.',
          style: GoogleFonts.dmSans(fontSize: 15, color: kGrey, height: 1.85)),
      const SizedBox(height: 36),
      Wrap(spacing: 10, runSpacing: 10,
          children: ['Brand Identity', 'UI/UX Design', 'Flutter Dev', 'Motion Design', 'Logo Design']
              .map((s) => _AnimatedSkillTag(label: s))
              .toList()),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  SERVICES SECTION  (original logic, ★ shimmer title)
  // ══════════════════════════════════════════════════════════════
  static const _services = [
    ('01', Icons.phone_android_rounded,'Mobile App Dev',  'Cross-platform Flutter apps with beautiful UIs and Firebase-powered backends.'),
    ('02', Icons.desktop_mac_rounded,  'UI/UX Design',    'User-centered design for apps and web — wireframes, prototypes, polished interfaces.'),
    ('03', Icons.print_rounded,        'Print Design',    'Flyers, posters, banners, and publications designed for maximum visual impact.'),
    ('04', Icons.code_rounded,         'Web Development', 'Responsive, animated websites that convert visitors and showcase your brand.'),
  ];

  Widget _servicesSection(Size size, bool mobile) {
    return _RevealSection(
      sectionKey: _servicesKey,
      visible: _servicesVis,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 30 : 100, vertical: 100),
        color: kSurface,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionBadge('WHAT I DO'),
          const SizedBox(height: 12),
          // ★ Shimmer title
          _ShimmerTitle(
            text: 'Services',
            style: GoogleFonts.bebasNeue(
                fontSize: mobile ? 54 : 80, color: kWhite, letterSpacing: 6),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(builder: (ctx, bc) {
            int cols = bc.maxWidth < 600 ? 1 : bc.maxWidth < 960 ? 2 : 3;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: bc.maxWidth < 600 ? 2.0 : 1.35,
              children: _services.asMap().entries.map((e) => _ServiceCard(
                num: e.value.$1,
                icon: e.value.$2,
                title: e.value.$3,
                desc: e.value.$4,
                delay: Duration(milliseconds: e.key * 80),
              )).toList(),
            );
          }),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PORTFOLIO SECTION  (original logic, ★ shimmer title)
  // ══════════════════════════════════════════════════════════════
  static final _works = [
    _PortfolioItem(title: 'TUBEBOOK',  category: 'Mobile App / WEB APP',    bg: const Color(0xFF1A2540), imagePath: 'assets/images/tubebook.png', tags: ['Logo', 'Identity', 'Colors']),
    _PortfolioItem(title: 'Hajiafidausshop',     category: 'Mobile App / WEB APP',  bg: const Color(0xFF1A1A12), imagePath: 'assets/images/Hajiafidausshop.png', tags: ['Flutter', 'UI/UX', 'Firebase']),
    _PortfolioItem(title: 'GOTALLYBOOK',  category: 'Mobile App / WEB APP',       bg: const Color(0xFF1A1030), imagePath: 'assets/images/GOTALLYBOOK.png', tags: ['Print', 'Illustration', 'Typography']),
    _PortfolioItem(title: 'BUY CHEAP BUNDLE',  category: 'Mobile App / WEB APP',    bg: const Color(0xFF0D2020), imagePath: 'assets/images/buycheapbundle.png', tags: ['Brand', 'Stationery', 'Guidelines']),
    _PortfolioItem(title: 'ANN VETEMENT', category: 'Mobile App / WEB APP', bg: const Color(0xFF1A0E22), imagePath: 'assets/images/ann vetement.png', tags: ['Flutter', 'Firebase', 'Payments']),
    _PortfolioItem(title: 'GO COMPLAINT',  category: 'Mobile App / WEB APP',      bg: const Color(0xFF1A1510), imagePath: 'assets/images/gocomplaint.png', tags: ['Motion', 'Video', 'Branding']),
    _PortfolioItem(title: 'POTSEC STUDENT REGISTRATION',  category: 'Mobile App / WEB APP',      bg: const Color(0xFF1A1510), imagePath: 'assets/images/potsec student registration.png', tags: ['Motion', 'Video', 'Branding']),

    _PortfolioItem(title: 'GO PUMPLOG',  category: 'Mobile App / WEB APP',      bg: const Color(0xFF1A1510), imagePath: 'assets/images/logo.jpg', tags: ['Motion', 'Video', 'Branding']),

    _PortfolioItem(title: 'YOA BOAME',  category: 'Mobile App / WEB APP',      bg: const Color(0xFF1A1510), imagePath: 'assets/images/logo.jpg', tags: ['Motion', 'Video', 'Branding']),

    _PortfolioItem(title: 'POTSEC STUDENT PORTAL',  category: 'Mobile App / WEB APP',      bg: const Color(0xFF1A1510), imagePath: 'assets/images/logo.jpg', tags: ['Motion', 'Video', 'Branding']),

    _PortfolioItem(title: 'SWALAHA  BEAUTY PRO',  category: 'Mobile App / WEB APP',      bg: const Color(0xFF1A1510), imagePath: 'assets/images/logo.jpg', tags: ['Motion', 'Video', 'Branding']),


  ];

  static const _filters = ['All', 'Mobile App / WEB APP',];

  Widget _portfolioSection(Size size, bool mobile) {
    final filtered = _activeFilter == 'All'
        ? _works
        : _works.where((w) => w.category == _activeFilter).toList();

    return _RevealSection(
      sectionKey: _portfolioKey,
      visible: _portfolioVis,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 100, vertical: 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionBadge('MY WORK'),
                const SizedBox(height: 12),
                // ★ Shimmer title
                _ShimmerTitle(
                  text: 'Portfolio',
                  style: GoogleFonts.bebasNeue(
                      fontSize: mobile ? 54 : 80, color: kWhite, letterSpacing: 6),
                ),
              ]),
              if (!mobile) _OutlineBtn(
                  label: 'HIRE ME', onTap: () =>
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context){
                return BookingPage();
              }))
              )
            ],
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) => _FilterChip(
                label: f,
                active: _activeFilter == f,
                onTap: () => setState(() => _activeFilter = f),
              )).toList(),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '${filtered.length} Project${filtered.length == 1 ? "" : "s"}',
            style: GoogleFonts.dmSans(fontSize: 12, color: kGrey, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: LayoutBuilder(
              key: ValueKey(_activeFilter),
              builder: (ctx, bc) {
                final cols = bc.maxWidth < 600 ? 1 : 2;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.42,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _PortfolioCard(item: filtered[i]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TESTIMONIALS  (original logic, ★ shimmer title)
  // ══════════════════════════════════════════════════════════════
  static const _testis = [

    ('Hakeem',   'Graphic Designer',
    'The Flutter app he built for us is stunning — users love it. Professional, fast, and incredibly talented.'),

  ];

  Widget _testimonialsSection(Size size, bool mobile) {
    return _RevealSection(
      sectionKey: _testimonialsKey,
      visible: _testisVis,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 100),
        color: kSurface,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mobile ? 30 : 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionBadge('CLIENT LOVE'),
              const SizedBox(height: 12),
              _ShimmerTitle(
                text: 'Testimonials',
                style: GoogleFonts.bebasNeue(
                    fontSize: mobile ? 54 : 80, color: kWhite, letterSpacing: 6),
              ),
            ]),
          ),
          const SizedBox(height: 52),
          SizedBox(
            height: 270,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: mobile ? 30 : 100),
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemCount: _testis.length,
              itemBuilder: (_, i) => _TestiCard(
                name: _testis[i].$1,
                role: _testis[i].$2,
                quote: _testis[i].$3,
                isMobile: mobile,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  CONTACT SECTION  (original)
  // ══════════════════════════════════════════════════════════════
  Widget _contactSection(Size size, bool mobile) {
    return _RevealSection(
      sectionKey: _contactKey,
      visible: _contactVis,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 30 : 100, vertical: 100),
        child: mobile
            ? Column(children: [_contactInfo(), const SizedBox(height: 48), _contactForm()])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: _contactInfo()),
          const SizedBox(width: 80),
          Expanded(flex: 3, child: _contactForm()),
        ]),
      ),
    );
  }

  Widget _contactInfo() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionBadge('GET IN TOUCH'),
      const SizedBox(height: 18),
      Text("Let's Create\nSomething\nAmazing",
          style: GoogleFonts.bebasNeue(fontSize: 58, color: kWhite, letterSpacing: 4, height: 1.0)),
      const SizedBox(height: 10),
      Container(width: 60, height: 3, color: kGold),
      const SizedBox(height: 28),
      Text(
          "Whether you need a brand identity, a mobile app, or a full creative package — "
              "I'm ready to bring your vision to life.",
          style: GoogleFonts.dmSans(fontSize: 15, color: kLightGrey, height: 1.85)),
      const SizedBox(height: 40),
      _contactRow(Icons.email_outlined,       'mustapharahman0544@gmail.com'),
      const SizedBox(height: 16),
      _contactRow(Icons.phone_outlined,       '+233551597865'),
      const SizedBox(height: 16),
      _contactRow(Icons.location_on_outlined, 'Kumasi, Ghana'),
    ]);
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, color: kGold, size: 18),
      const SizedBox(width: 14),
      Text(text, style: GoogleFonts.dmSans(fontSize: 14, color: kLightGrey)),
    ]);
  }

  Widget _contactForm() {
    return _AnimatedBorderCard(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: kCard, border: Border.all(color: kBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Send a Message',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 28, color: kWhite, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          _field('Your Name'),
          const SizedBox(height: 14),
          _field('Email Address'),
          const SizedBox(height: 14),
          _field('Project Type  (Branding / App / Web...)'),
          const SizedBox(height: 14),
          _field('Your Message', lines: 5),
          const SizedBox(height: 28),
          _GlowButton(label: 'SEND MESSAGE', onTap: () {}, fullWidth: true),
        ]),
      ),
    );
  }

  Widget _field(String hint, {int lines = 1}) {
    return TextFormField(
      maxLines: lines,
      style: GoogleFonts.dmSans(color: kWhite, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: kGrey, fontSize: 14),
        filled: true, fillColor: kSurface,
        border:        _inputBorder(kBorder),
        enabledBorder: _inputBorder(kBorder),
        focusedBorder: _inputBorder(kGold),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color c) =>
      OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: c));

  // ══════════════════════════════════════════════════════════════
  //  FOOTER  (original)
  // ══════════════════════════════════════════════════════════════
  Widget _footer(Size size, bool mobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 30 : 100, vertical: 36),
      decoration: BoxDecoration(
          color: kSurface,
          border: Border(top: BorderSide(color: kBorder))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('© 2026 Mustapha Abdul Rahman',
            style: GoogleFonts.dmSans(fontSize: 12, color: kGrey)),
        if (!mobile)
          Text('Designed & Developed with ♥ in Ghana',
              style: GoogleFonts.dmSans(fontSize: 12, color: kGrey)),
      ]),
    );
  }

  // ── Section badge label (original)
  Widget _sectionBadge(String label) {
    return Row(children: [
      Container(width: 22, height: 1, color: kGold),
      const SizedBox(width: 12),
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 10, color: kGold, letterSpacing: 4, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════
//  ★ NEW: ANIMATED STAT WIDGET  (counts up from 0)
// ════════════════════════════════════════════════════════════════

class _AnimatedStatWidget extends StatelessWidget {
  final String numStr;
  final String label;
  const _AnimatedStatWidget(this.numStr, this.label);

  @override
  Widget build(BuildContext context) {
    final num = int.tryParse(numStr.replaceAll('+', '').replaceAll('>', '')) ?? 0;
    final hasPlus = numStr.contains('+');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: num.toDouble()),
        duration: const Duration(milliseconds: 2600),
        curve: Curves.easeOut,
        builder: (_, val, __) => Text(
          '${val.round()}${hasPlus ? '+' : ''}',
          style: GoogleFonts.bebasNeue(fontSize: 38, color: kGold, letterSpacing: 2),
        ),
      ),
      Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: kGrey, letterSpacing: 1.5)),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════
//  ★ NEW: ANIMATED SKILL TAG  (hover fill + slide)
// ════════════════════════════════════════════════════════════════

class _AnimatedSkillTag extends StatefulWidget {
  final String label;
  const _AnimatedSkillTag({required this.label});
  @override State<_AnimatedSkillTag> createState() => _AnimatedSkillTagState();
}

class _AnimatedSkillTagState extends State<_AnimatedSkillTag> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit:  (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: _h ? kGold : kBorder),
          color: _h ? kGoldGlow : kCard,
        ),
        child: Text(widget.label,
            style: GoogleFonts.dmSans(
                fontSize: 12,
                color: _h ? kGold : kLightGrey,
                letterSpacing: 1.2)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  REUSABLE COMPONENTS  (original + enhanced)
// ════════════════════════════════════════════════════════════════

// ── Scroll-reveal wrapper  ★ enhanced with scale
class _RevealSection extends StatefulWidget {
  final GlobalKey sectionKey;
  final bool visible;
  final Widget child;
  const _RevealSection({required this.sectionKey, required this.visible, required this.child});
  @override State<_RevealSection> createState() => _RevealSectionState();
}

class _RevealSectionState extends State<_RevealSection> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fade  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    // ★ Scale from 0.96 → 1.0
    _scale = Tween<double>(begin: 0.96, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_RevealSection old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Container(key: widget.sectionKey, child: widget.child),
        ),
      ),
    );
  }
}

// ── Glowing Gold Button  ★ extra rings on hover
class _GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool small;
  final bool fullWidth;
  const _GlowButton({
    required this.label, required this.onTap,
    this.small = false, this.fullWidth = false,
  });
  @override State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  // ★ Ring controllers
  late AnimationController _ring1Ctrl, _ring2Ctrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 5, end: 18).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _ring1Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _ring2Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() => _hovered = true);
    _ring1Ctrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ring2Ctrl.forward(from: 0);
    });
  }

  void _onExit() {
    setState(() => _hovered = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(),
      onExit:  (_) => _onExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulse, _ring1Ctrl, _ring2Ctrl]),
          builder: (_, __) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ★ Ring 1
                if (_hovered)
                  Positioned.fill(
                    child: Transform.scale(
                      scale: 1 + _ring1Ctrl.value * 0.6,
                      child: Opacity(
                        opacity: (1 - _ring1Ctrl.value).clamp(0, 1) * 0.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: kGold, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                // ★ Ring 2
                if (_hovered)
                  Positioned.fill(
                    child: Transform.scale(
                      scale: 1 + _ring2Ctrl.value * 0.9,
                      child: Opacity(
                        opacity: (1 - _ring2Ctrl.value).clamp(0, 1) * 0.3,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: kGold, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Main button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: widget.fullWidth ? double.infinity : null,
                  padding: EdgeInsets.symmetric(
                      horizontal: widget.small ? 20 : 34,
                      vertical:   widget.small ? 12 : 18),
                  decoration: BoxDecoration(
                    color: _hovered ? const Color(0xFFEDD97A) : kGold,
                    boxShadow: [BoxShadow(
                      color: kGold.withOpacity(_hovered ? 0.65 : 0.3),
                      blurRadius: _hovered ? _pulse.value + 10 : _pulse.value,
                      spreadRadius: _hovered ? 3 : 0,
                    )],
                  ),
                  child: Center(
                    child: Text(widget.label,
                        style: GoogleFonts.dmSans(
                            fontSize: widget.small ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: kBg, letterSpacing: 3.5)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Outline Button (original)
class _OutlineBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool small;
  const _OutlineBtn({required this.label, required this.onTap, this.small = false});
  @override State<_OutlineBtn> createState() => _OutlineBtnState();
}
class _OutlineBtnState extends State<_OutlineBtn> {
  bool _hovered = false;
  @override Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
              horizontal: widget.small ? 20 : 34,
              vertical:   widget.small ? 12 : 18),
          decoration: BoxDecoration(
              color: _hovered ? kGold.withOpacity(0.1) : Colors.transparent,
              border: Border.all(color: _hovered ? kGold : kLightGrey.withOpacity(0.45))),
          child: Text(widget.label,
              style: GoogleFonts.dmSans(
                  fontSize: widget.small ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: _hovered ? kGold : kWhite,
                  letterSpacing: 3.5)),
        ),
      ),
    );
  }
}

// ── Nav Link (original)
class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink(this.label, this.onTap);
  @override State<_NavLink> createState() => _NavLinkState();
}
class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;
  @override Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.dmSans(
                fontSize: 12,
                color: _hovered ? kGold : kLightGrey,
                letterSpacing: 2.2,
                fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ── Service Card  ★ animated icon glow + shimmer border on hover
class _ServiceCard extends StatefulWidget {
  final String num, title, desc;
  final IconData icon;
  final Duration delay;
  const _ServiceCard({
    required this.num, required this.icon,
    required this.title, required this.desc, required this.delay,
  });
  @override State<_ServiceCard> createState() => _ServiceCardState();
}
class _ServiceCardState extends State<_ServiceCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _iconCtrl;
  late Animation<double> _iconPulse;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _iconPulse = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _iconCtrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: _iconPulse,
        builder: (_, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _hovered ? kCard : kBg,
            border: Border.all(color: _hovered ? kGold.withOpacity(0.45) : kBorder),
            boxShadow: _hovered
                ? [BoxShadow(color: kGold.withOpacity(0.08 + _iconPulse.value * 0.06), blurRadius: 32, spreadRadius: 2)]
                : [],
          ),
          child: child,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              AnimatedBuilder(
                animation: _iconPulse,
                builder: (_, __) => AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: _hovered ? kGoldGlow : kSurface,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _hovered
                        ? [BoxShadow(color: kGold.withOpacity(0.2 + _iconPulse.value * 0.15), blurRadius: 18)]
                        : [],
                  ),
                  child: Icon(widget.icon, color: _hovered ? kGold : kGrey, size: 22),
                ),
              ),
              Text(widget.num,
                  style: GoogleFonts.bebasNeue(
                      fontSize: 34, letterSpacing: 2,
                      color: _hovered ? kGold.withOpacity(0.25) : kBorder)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title,
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 22, color: kWhite, fontWeight: FontWeight.w700)),
              const SizedBox(height: 7),
              Text(widget.desc,
                  style: GoogleFonts.dmSans(fontSize: 13, color: kGrey, height: 1.7)),
            ]),
            if (_hovered) Row(children: [
              Text('Learn more',
                  style: GoogleFonts.dmSans(fontSize: 11, color: kGold, letterSpacing: 1.5)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: kGold, size: 13),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Portfolio Item Model (original)
class _PortfolioItem {
  final String title, category, imagePath;
  final Color bg;
  final List<String> tags;
  const _PortfolioItem({
    required this.title, required this.category,
    required this.imagePath, required this.bg, required this.tags,
  });
}

// ── Filter Chip (original)
class _FilterChip extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});
  @override State<_FilterChip> createState() => _FilterChipState();
}
class _FilterChipState extends State<_FilterChip> {
  bool _h = false;
  @override Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit:  (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: widget.active ? kGold : (_h ? kGoldGlow : kCard),
            border: Border.all(
                color: widget.active ? kGold : (_h ? kGold.withOpacity(0.4) : kBorder)),
          ),
          child: Text(widget.label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: widget.active ? kBg : (_h ? kGold : kLightGrey),
                fontWeight: widget.active ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 1.8,
              )),
        ),
      ),
    );
  }
}

// ── Portfolio Card  ★ 3D tilt on hover
class _PortfolioCard extends StatefulWidget {
  final _PortfolioItem item;
  const _PortfolioCard({required this.item});
  @override State<_PortfolioCard> createState() => _PortfolioCardState();
}
class _PortfolioCardState extends State<_PortfolioCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _ctrl;
  late Animation<double> _overlay;
  late Animation<double> _zoom;

  // ★ Tilt tracking
  double _tiltX = 0, _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _overlay = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _zoom = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Matrix4 _buildTiltMatrix() {
    if (!_hovered) return Matrix4.identity();
    return Matrix4.identity()
      ..setEntry(3, 2, 0.0008)
      ..rotateX(-_tiltY * 0.07)
      ..rotateY(_tiltX * 0.07);
  }

  @override Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) { setState(() => _hovered = true);  _ctrl.forward(); },
      onExit:  (_) {
        setState(() { _hovered = false; _tiltX = 0; _tiltY = 0; });
        _ctrl.reverse();
      },
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(event.position);
        setState(() {
          _tiltX = (local.dx / box.size.width  - 0.5) * 2;
          _tiltY = (local.dy / box.size.height - 0.5) * 2;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: _buildTiltMatrix(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.item.bg,
          boxShadow: _hovered
              ? [
            BoxShadow(color: kGold.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 10)),
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 36, offset: const Offset(0, 14)),
          ]
              : [],
        ),
        child: ClipRect(
          child: Stack(children: [

            // Background image (zooms on hover)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _zoom,
                builder: (_, child) => Transform.scale(scale: _zoom.value, child: child),
                child: Image.asset(
                  widget.item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: widget.item.bg,
                    child: Center(child: Icon(Icons.image_not_supported_outlined, color: kGrey, size: 40)),
                  ),
                ),
              ),
            ),

            // Always-on gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.75)],
                  ),
                ),
              ),
            ),

            // Grid texture overlay
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),

            // ★ Animated border card overlay
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _hovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _AnimatedBorderCard(borderWidth: 1.5, child: const SizedBox.expand()),
                ),
              ),
            ),

            // Category badge
            Positioned(
              top: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                color: kGold.withOpacity(0.88),
                child: Text(widget.item.category.toUpperCase(),
                    style: GoogleFonts.dmSans(fontSize: 9, color: kBg,
                        letterSpacing: 2.5, fontWeight: FontWeight.w700)),
              ),
            ),

            // Bottom info bar
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: widget.item.tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(color: kGold.withOpacity(0.3))),
                      child: Text(t, style: GoogleFonts.dmSans(fontSize: 9, color: kGold, letterSpacing: 1.5)),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.item.title,
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 24, color: kWhite, fontWeight: FontWeight.w700, letterSpacing: 1)),
                ]),
              ),
            ),

            // Hover overlay with action
            FadeTransition(
              opacity: _overlay,
              child: Container(
                color: Colors.black.withOpacity(0.55),
                child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: kGold, width: 1.5),
                          shape: BoxShape.circle,
                          color: kGoldGlow,
                          boxShadow: [BoxShadow(color: kGold.withOpacity(0.35), blurRadius: 24)],
                        ),
                        child: const Icon(Icons.open_in_new_rounded, color: kGold, size: 22)),
                    const SizedBox(height: 16),
                    Text(widget.item.title,
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 26, color: kWhite, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(widget.item.category,
                        style: GoogleFonts.dmSans(fontSize: 11, color: kGold, letterSpacing: 2.5)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                      decoration: BoxDecoration(
                          border: Border.all(color: kGold),
                          color: kGoldGlow),
                      child: Text('VIEW PROJECT',
                          style: GoogleFonts.dmSans(fontSize: 10, color: kGold,
                              letterSpacing: 2.5, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Grid Texture Painter (original)
class _GridPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.025)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override bool shouldRepaint(_) => false;
}

// ── Testimonial Card  ★ wrapped in animated border
class _TestiCard extends StatelessWidget {
  final String name, role, quote;
  final bool isMobile;
  const _TestiCard({required this.name, required this.role, required this.quote, required this.isMobile});

  @override Widget build(BuildContext context) {
    return _AnimatedBorderCard(
      borderWidth: 1,
      child: Container(
        width: isMobile ? 300 : 420,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(color: kCard, border: Border.all(color: kBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('"',
                style: GoogleFonts.cormorantGaramond(fontSize: 72, color: kGold, height: 0.8)),
            Expanded(
                child: Text(quote,
                    style: GoogleFonts.cormorantGaramond(
                        fontSize: 17, color: kOffWhite, fontStyle: FontStyle.italic, height: 1.7))),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 28, height: 1, color: kGold),
              const SizedBox(height: 12),
              Text(name,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: kWhite, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              Text(role,
                  style: GoogleFonts.dmSans(fontSize: 12, color: kGrey)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Bouncing Arrow (original)
class _BouncingArrow extends StatefulWidget {
  const _BouncingArrow();
  @override State<_BouncingArrow> createState() => _BouncingArrowState();
}
class _BouncingArrowState extends State<_BouncingArrow> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: 9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, __) => Transform.translate(
          offset: Offset(0, _bounce.value),
          child: const Icon(Icons.keyboard_arrow_down, color: kGold, size: 22)),
    );
  }
}