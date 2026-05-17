import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/costalina_logo.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // 4 water ripple rings
  late final List<AnimationController> _ripples;
  late final AnimationController _logo;
  late final AnimationController _words;
  late final AnimationController _bar;

  @override
  void initState() {
    super.initState();
    _ripples = List.generate(
      4,
      (i) => AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1100)),
    );
    _logo  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _words = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _bar   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _run();
  }

  Future<void> _run() async {
    // Stagger 4 ripples 200 ms apart from the center
    for (var i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 220), () {
        if (mounted) _ripples[i].forward();
      });
    }
    // Logo appears after first ripple starts expanding
    await Future.delayed(const Duration(milliseconds: 280));
    if (mounted) _logo.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _words.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _bar.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final loggedIn = await AuthService.restoreSession();
    if (loggedIn) {
      if (mounted) Navigator.pushReplacementNamed(context, '/app');
      return;
    }
    final hasSeen = await OnboardingScreen.hasSeen();
    if (mounted) {
      Navigator.pushReplacementNamed(context, hasSeen ? '/login' : '/onboarding');
    }
  }

  @override
  void dispose() {
    for (final c in _ripples) { c.dispose(); }
    _logo.dispose();
    _words.dispose();
    _bar.dispose();
    super.dispose();
  }

  Widget _ripple(AnimationController c, double maxRadius) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, _) {
        final t = Curves.easeOut.transform(c.value);
        return Opacity(
          opacity: (1.0 - t) * 0.55,
          child: Container(
            width: maxRadius * t * 2,
            height: maxRadius * t * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CColors.teal.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: CColors.sand,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ── Water ripples — 4 expanding rings ────────────────────────
          _ripple(_ripples[0], size.width * 0.75),
          _ripple(_ripples[1], size.width * 0.62),
          _ripple(_ripples[2], size.width * 0.50),
          _ripple(_ripples[3], size.width * 0.38),

          // ── Centre content ────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Real Costalina logo with spring scale-in
              AnimatedBuilder(
                animation: _logo,
                builder: (_, _) {
                  final t = Curves.elasticOut.transform(_logo.value);
                  return Opacity(
                    opacity: _logo.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.4 + 0.6 * t,
                      child: CostalinaLogo(size: 180, bgColor: CColors.sand),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Subtitle
              AnimatedBuilder(
                animation: _words,
                builder: (_, _) {
                  final t = Curves.easeOut.transform(_words.value);
                  return Opacity(
                    opacity: t * 0.65,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - t)),
                      child: Text(
                        'LITTORAL TUNISIEN · 2026',
                        style: CType.eyebrow(
                          size: 9,
                          tracking: 0.32,
                          color: CColors.tealDark,
                          w: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Progress hairline
              AnimatedBuilder(
                animation: _words,
                builder: (_, child) =>
                    Opacity(opacity: _words.value, child: child),
                child: Container(
                  width: 120,
                  height: 1,
                  color: CColors.tealLine,
                  child: AnimatedBuilder(
                    animation: _bar,
                    builder: (_, _) => Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _bar.value,
                        child: ColoredBox(color: CColors.tealDark),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom tagline ────────────────────────────────────────────
          Positioned(
            bottom: 48,
            child: AnimatedBuilder(
              animation: _words,
              builder: (_, _) => Opacity(
                opacity: _words.value * 0.55,
                child: Text(
                  'Surveillance du trait de côte',
                  style: CType.body(
                      size: 11, color: CColors.tealDark, w: FontWeight.w300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}