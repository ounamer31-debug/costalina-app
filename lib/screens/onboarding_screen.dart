import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/costalina_logo.dart';
import '../widgets/eyebrow.dart';
import '../widgets/serif_title.dart';

const _onboardedKey = 'has_seen_onboarding';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pager = PageController();
  int _i = 0;

  static const _pages = [
    _OnboardPage(
      kicker: 'BIENVENUE',
      title: 'Surveillez ',
      italic: 'le littoral',
      body:
          'Costalina est une plateforme de science citoyenne dédiée à la surveillance de l\'érosion côtière en Tunisie. Ensemble, nous protégeons nos plages.',
      icon: LucideIcons.waves,
    ),
    _OnboardPage(
      kicker: 'CONTRIBUER',
      title: 'Vos signalements ',
      italic: 'comptent',
      body:
          'À la plage ? Signalez l\'érosion, la pollution ou les dégâts. Chaque rapport, vérifié par notre équipe, alimente la cartographie des risques.',
      icon: LucideIcons.camera,
    ),
    _OnboardPage(
      kicker: 'AGIR',
      title: 'Alertes ',
      italic: 'en temps réel',
      body:
          'Recevez des alertes sur les plages à risque. Suivez les évolutions et partagez vos observations avec la communauté côtière.',
      icon: LucideIcons.bellRing,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _next() {
    if (_i < _pages.length - 1) {
      _pager.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() { _pager.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Row(
                children: [
                  const CostalinaLogo(size: 32),
                  const Spacer(),
                  if (_i < _pages.length - 1)
                    GestureDetector(
                      onTap: _finish,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'Passer',
                          style: CType.eyebrow(
                            size: 10,
                            tracking: 0.24,
                            color: p.inkSoft,
                            w: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pager,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _i = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            // Page dots
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < _pages.length; j++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: j == _i ? 24 : 8,
                      height: 4,
                      color: j == _i ? CColors.tealDark : CColors.tealLine,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
              child: GestureDetector(
                onTap: _next,
                child: Container(
                  height: 52,
                  color: CColors.tealDark,
                  alignment: Alignment.center,
                  child: Text(
                    _i == _pages.length - 1 ? 'COMMENCER  →' : 'SUIVANT  →',
                    style: CType.eyebrow(
                      size: 11,
                      tracking: 0.22,
                      color: Colors.white,
                      w: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String kicker;
  final String title;
  final String italic;
  final String body;
  final IconData icon;
  const _OnboardPage({
    required this.kicker,
    required this.title,
    required this.italic,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: CColors.tealBg,
              border: Border.all(color: CColors.tealLine),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 38, color: CColors.tealDark),
          ),
          const SizedBox(height: 30),
          Eyebrow(kicker),
          const SizedBox(height: 12),
          SerifTitle(title, italic: italic, trail: '.', size: 32),
          const SizedBox(height: 18),
          Container(
            width: 60,
            height: 1,
            color: CColors.tealDark,
          ),
          const SizedBox(height: 18),
          Text(
            body,
            style: CType.body(size: 14, color: p.inkSoft),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}