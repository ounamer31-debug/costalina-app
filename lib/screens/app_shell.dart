import 'package:flutter/material.dart';

import '../main.dart' show tabNotifier, localeNotifier;
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'alertes_screen.dart';
import 'profil_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    tabNotifier.addListener(_onTabNotifier);
    localeNotifier.addListener(_onLocale);
  }

  @override
  void dispose() {
    tabNotifier.removeListener(_onTabNotifier);
    localeNotifier.removeListener(_onLocale);
    super.dispose();
  }

  void _onLocale() { if (mounted) setState(() {}); }

  void _onTabNotifier() {
    if (mounted && tabNotifier.value != _index) {
      setState(() => _index = tabNotifier.value);
    }
  }

  void _setTab(int i) {
    setState(() => _index = i);
    tabNotifier.value = i;
  }

  void _openReportSheet() {
    showCreateReportSheet(context, isPhoto: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.sand,
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(),
          MapScreen(),
          AlertesScreen(),
          ProfilScreen(),
        ],
      ),
      bottomNavigationBar: CostalinaBottomNav(
        currentIndex: _index,
        onTap: _setTab,
        onFabTap: _openReportSheet,
      ),
    );
  }
}