import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/reward.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/eyebrow.dart';
import '../widgets/hair_line.dart';
import '../widgets/serif_title.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  List<Reward> _rewards = const [];
  bool _loading = true;
  String? _error;
  String? _redeemingId;

  @override
  void initState() {
    super.initState();
    // Defer load to after first frame to avoid setState-during-build issues
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final rewards = await ApiService.getRewards();
      await AuthService.refreshMe();
      if (!mounted) return;
      setState(() {
        _rewards = rewards;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  int get _points => AuthService.currentUser?.points ?? 0;

  Future<void> _redeem(Reward r) async {
    if (_redeemingId != null) return;
    if (_points < r.cost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Points insuffisants — il vous manque ${r.cost - _points} pts',
            style: CType.body(size: 13, color: Colors.white)),
        backgroundColor: CColors.amberInk,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final confirmed = await _confirmDialog(r);
    if (confirmed != true) return;

    setState(() => _redeemingId = r.id);
    final result = await ApiService.redeemReward(r.id);
    await AuthService.refreshMe();
    if (!mounted) return;
    setState(() => _redeemingId = null);

    if (result.success) {
      _showSuccessSheet(result.redemption!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Échec: ${result.error ?? "inconnu"}',
            style: CType.body(size: 13, color: Colors.white)),
        backgroundColor: CColors.redInk,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<bool?> _confirmDialog(Reward r) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette(ctx).bg,
        shape: const RoundedRectangleBorder(),
        title: Text('Échanger ${r.cost} pts ?',
            style: CType.serifDisplay(size: 19, color: palette(ctx).ink)),
        content: Text(
          'Vous échangez ${r.cost} points contre "${r.name}". Cette action ne peut pas être annulée.',
          style: CType.body(size: 13, color: palette(ctx).inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('ANNULER',
                style: CType.eyebrow(size: 10, tracking: 0.24, color: CColors.grey, w: FontWeight.w400)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('CONFIRMER',
                style: CType.eyebrow(size: 10, tracking: 0.24, color: CColors.tealDark, w: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSheet(Redemption redemption) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      shape: const RoundedRectangleBorder(),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: CColors.greenInk.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.partyPopper, size: 22, color: CColors.greenInk),
                ),
                const SizedBox(width: 12),
                Text('Échange réussi',
                    style: CType.serifDisplay(size: 22, color: palette(context).ink)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(redemption.rewardName,
                style: CType.serifDisplay(size: 18, color: palette(context).ink)),
            const SizedBox(height: 16),
            const Eyebrow('CODE DE RÉCLAMATION'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                color: CColors.tealBg,
                border: Border.all(color: CColors.tealLine),
              ),
              child: Text(
                redemption.code,
                style: CType.serifDisplay(size: 28, color: CColors.tealDark),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Présentez ce code chez notre partenaire pour récupérer votre récompense.',
              style: CType.body(size: 12, color: palette(context).inkSoft),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: CColors.tealDark,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 60),
            children: [
              _buildHeader(context, p),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('DÉFI PHOTO IA'),
                    const SizedBox(height: 10),
                    SerifTitle('Gagnez ', italic: 'des points cadeaux', size: 30),
                    const SizedBox(height: 14),
                    Text(
                      'Partagez une photo claire de la plage pour aider l\'IA à analyser l\'érosion. Les meilleures contributions remportent des expériences Costalina.',
                      style: CType.body(size: 13, color: p.inkSoft),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _PointsBlock(
                          value: '$_points',
                          label: 'POINTS',
                          background: const Color(0xFFF5E9C9),
                          textColor: const Color(0xFF66491F),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PointsBlock(
                          value: '+20',
                          label: 'PAR PHOTO UTILE',
                          background: CColors.tealBg,
                          textColor: CColors.tealDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                child: Eyebrow('RÉCOMPENSES DISPONIBLES'),
              ),
              _buildBody(p),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: GestureDetector(
                  onTap: () => _showHistory(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: CColors.tealLineSoft, width: 1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.history, size: 16, color: CColors.tealDark),
                        const SizedBox(width: 10),
                        Text('Historique des échanges',
                            style: CType.body(size: 13, color: p.ink, w: FontWeight.w500)),
                        const Spacer(),
                        Text('→', style: CType.body(size: 16, color: CColors.tealDark, w: FontWeight.w300)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CoastPalette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Icon(LucideIcons.arrowLeft, size: 20, color: CColors.tealDark),
            ),
          ),
          const SizedBox(width: 6),
          Text('Récompenses',
              style: CType.serifDisplay(size: 18, color: p.ink)),
          const Spacer(),
          if (!_loading)
            GestureDetector(
              onTap: _load,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(LucideIcons.refreshCw, size: 16, color: CColors.tealDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(CoastPalette p) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(22, 40, 22, 40),
        child: Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: CColors.teal),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
        child: Column(
          children: [
            const Icon(LucideIcons.wifiOff, size: 32, color: CColors.grey),
            const SizedBox(height: 12),
            Text('Impossible de charger les récompenses',
                style: CType.body(size: 13, color: p.inkSoft),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: CColors.tealDark,
                child: Text('Réessayer',
                    style: CType.eyebrow(size: 10, tracking: 0.22, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    if (_rewards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
        child: Column(
          children: [
            const Icon(LucideIcons.gift, size: 32, color: CColors.grey),
            const SizedBox(height: 12),
            Text('Aucune récompense disponible pour le moment',
                style: CType.body(size: 13, color: p.inkSoft),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          for (final r in _rewards) ...[
            _RewardCard(
              reward: r,
              unlocked: _points >= r.cost,
              redeeming: _redeemingId == r.id,
              onTap: () => _redeem(r),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (ctx, ctrl) => FutureBuilder<List<Redemption>>(
          future: ApiService.getMyRedemptions(),
          builder: (ctx2, snap) {
            final list = snap.data ?? const <Redemption>[];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                  child: Row(
                    children: [
                      Text('Historique',
                          style: CType.serifDisplay(size: 22, color: palette(ctx2).ink)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx2),
                        child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
                      ),
                    ],
                  ),
                ),
                const HairLine(color: CColors.tealLine),
                Expanded(
                  child: snap.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: CColors.teal)),
                        )
                      : list.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: Text(
                                    'Aucun échange pour le moment.\nGagnez des points en faisant vérifier vos signalements.',
                                    style: CType.body(size: 13, color: palette(ctx2).inkSoft),
                                    textAlign: TextAlign.center),
                              ),
                            )
                          : ListView.separated(
                              controller: ctrl,
                              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                              itemCount: list.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (_, i) => _RedemptionRow(r: list[i]),
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

class _PointsBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color background;
  final Color textColor;
  const _PointsBlock({
    required this.value,
    required this.label,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: CType.serifDisplay(size: 32, color: textColor)),
          const SizedBox(height: 6),
          Text(label,
              style: CType.eyebrow(size: 9, tracking: 0.28, color: textColor, w: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;
  final bool unlocked;
  final bool redeeming;
  final VoidCallback onTap;
  const _RewardCard({
    required this.reward,
    required this.unlocked,
    required this.redeeming,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return GestureDetector(
      onTap: redeeming ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border.all(
              color: unlocked ? CColors.tealDark : CColors.tealLine, width: 1),
        ),
        child: Row(
          children: [
            if (reward.imageUrl.isNotEmpty)
              SizedBox(
                width: 96, height: 96,
                child: CachedNetworkImage(
                  imageUrl: reward.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ColoredBox(color: CColors.tealBg),
                  errorWidget: (_, _, _) => const ColoredBox(color: CColors.tealBg),
                ),
              )
            else
              Container(
                width: 96, height: 96,
                color: CColors.tealBg,
                alignment: Alignment.center,
                child: const Icon(LucideIcons.gift, size: 24, color: CColors.tealDark),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                      color: const Color(0xFFF5E9C9),
                      child: Text(
                        '${reward.cost} PTS',
                        style: CType.eyebrow(
                            size: 9, tracking: 0.28,
                            color: const Color(0xFF66491F),
                            w: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(reward.name,
                        style: CType.serifDisplay(size: 17, color: p.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(reward.description,
                        style: CType.body(size: 11, color: p.inkSoft),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            Container(
              width: 44, height: 96,
              color: unlocked ? CColors.tealDark : p.bg,
              alignment: Alignment.center,
              child: redeeming
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Icon(
                      unlocked ? LucideIcons.gift : LucideIcons.lock,
                      size: 18,
                      color: unlocked ? Colors.white : CColors.grey,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedemptionRow extends StatelessWidget {
  final Redemption r;
  const _RedemptionRow({required this.r});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    Color statusColor;
    switch (r.status) {
      case 'fulfilled': statusColor = CColors.greenInk; break;
      case 'cancelled': statusColor = CColors.redInk;   break;
      default:          statusColor = CColors.amberInk;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: CColors.tealLine, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(r.rewardName,
                  style: CType.serifDisplay(size: 16, color: p.ink))),
              Eyebrow(r.status, size: 9, tracking: 0.28, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text('Code: ${r.code}  ·  -${r.cost} pts',
              style: CType.body(size: 11, color: p.inkSoft)),
        ],
      ),
    );
  }
}