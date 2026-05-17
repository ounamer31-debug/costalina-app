import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/eyebrow.dart';
import '../widgets/hair_line.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getLeaderboard();
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService.getLeaderboard());
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final me = AuthService.currentUser;

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration: BoxDecoration(
                color: p.bg,
                border: const Border(bottom: BorderSide(color: CColors.tealLineSoft)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.arrowLeft, size: 20, color: CColors.tealDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Classement', style: CType.serifDisplay(size: 22, color: p.ink)),
                  ),
                  GestureDetector(
                    onTap: _refresh,
                    child: const Icon(LucideIcons.refreshCw, size: 18, color: CColors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<LeaderboardEntry>>(
                future: _future,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: CColors.tealDark)),
                    );
                  }
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return Center(
                      child: Text('Aucun participant pour l\'instant',
                          style: CType.body(size: 13, color: p.inkSoft)),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: CColors.tealDark,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 60),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final entry = list[i];
                        final rank  = i + 1;
                        final isMe  = me != null && me.id.isNotEmpty && entry.id == me.id;
                        return _LeaderboardRow(
                          entry: entry,
                          rank:  rank,
                          isMe:  isMe,
                          first: i == 0,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool isMe;
  final bool first;

  const _LeaderboardRow({
    required this.entry,
    required this.rank,
    required this.isMe,
    required this.first,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette(context);

    final medalColor = switch (rank) {
      1 => const Color(0xFFD4AF37),
      2 => const Color(0xFF9EA7AD),
      3 => const Color(0xFFCD7F32),
      _ => p.inkSoft,
    };

    final rankLabel = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#$rank',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!first) const HairLine(color: CColors.tealLineSoft),
        Container(
          color: isMe ? CColors.tealBg : Colors.transparent,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 36,
                child: rank <= 3
                    ? Text(rankLabel, style: const TextStyle(fontSize: 20))
                    : Text(rankLabel,
                        style: CType.serifDisplay(size: 14, color: medalColor)),
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CColors.tealBg,
                  border: Border.all(
                    color: isMe ? CColors.tealDark : CColors.tealLine,
                    width: isMe ? 2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: entry.avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: entry.avatarUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const Icon(
                          LucideIcons.user, size: 18, color: CColors.teal),
                      )
                    : const Icon(LucideIcons.user, size: 18, color: CColors.teal),
              ),
              const SizedBox(width: 14),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: CType.serifDisplay(
                        size: 16,
                        color: isMe ? CColors.tealDark : p.ink,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(height: 2),
                      Eyebrow('Vous', size: 9, tracking: 0.22, color: CColors.tealDark),
                    ],
                  ],
                ),
              ),
              // Points
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.points}',
                    style: CType.serifDisplay(size: 20, color: medalColor),
                  ),
                  Eyebrow('pts', size: 9, tracking: 0.2, color: p.inkSoft),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}