import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/api_service.dart';

enum BadgeTier { bronze, silver, gold, platinum }

class CoastBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final BadgeTier tier;
  final int threshold;
  final int progress;
  final bool earned;

  const CoastBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.tier,
    required this.threshold,
    required this.progress,
    required this.earned,
  });

  double get progressFraction {
    if (threshold <= 0) return 1.0;
    return (progress / threshold).clamp(0.0, 1.0);
  }
}

class BadgeService {
  static List<CoastBadge> compute(UserStats stats) {
    final t = stats.total;
    final v = stats.verified;

    return [
      _make(
        id: 'first_report',
        name: 'Première observation',
        description: 'Soumettre votre 1er signalement',
        icon: LucideIcons.flag,
        tier: BadgeTier.bronze,
        threshold: 1,
        progress: t,
      ),
      _make(
        id: 'sentinel_5',
        name: 'Sentinelle',
        description: '5 signalements soumis',
        icon: LucideIcons.eye,
        tier: BadgeTier.bronze,
        threshold: 5,
        progress: t,
      ),
      _make(
        id: 'observer_15',
        name: 'Vigie côtière',
        description: '15 signalements soumis',
        icon: LucideIcons.binary,
        tier: BadgeTier.silver,
        threshold: 15,
        progress: t,
      ),
      _make(
        id: 'guardian_50',
        name: 'Gardien du littoral',
        description: '50 signalements soumis',
        icon: LucideIcons.shield,
        tier: BadgeTier.gold,
        threshold: 50,
        progress: t,
      ),
      _make(
        id: 'verified_1',
        name: 'Première vérification',
        description: '1 signalement vérifié',
        icon: LucideIcons.badgeCheck,
        tier: BadgeTier.silver,
        threshold: 1,
        progress: v,
      ),
      _make(
        id: 'verified_10',
        name: 'Source fiable',
        description: '10 signalements vérifiés',
        icon: LucideIcons.award,
        tier: BadgeTier.gold,
        threshold: 10,
        progress: v,
      ),
    ];
  }

  static CoastBadge _make({
    required String id,
    required String name,
    required String description,
    required IconData icon,
    required BadgeTier tier,
    required int threshold,
    required int progress,
  }) {
    return CoastBadge(
      id: id,
      name: name,
      description: description,
      icon: icon,
      tier: tier,
      threshold: threshold,
      progress: progress,
      earned: progress >= threshold,
    );
  }

  static Color tierColor(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze:   return const Color(0xFFB07A3F);
      case BadgeTier.silver:   return const Color(0xFF8A99A6);
      case BadgeTier.gold:     return const Color(0xFFC9963B);
      case BadgeTier.platinum: return const Color(0xFF456A82);
    }
  }
}