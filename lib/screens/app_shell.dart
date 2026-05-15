import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  final _picker = ImagePicker();

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

  // ── AJOUTER: media source sheet ──────────────────────────────────────────────

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CColors.sand,
      shape: const RoundedRectangleBorder(),
      builder: (_) => _AddSheet(
        onPhoto: _takePhoto,
        onVideo: _takeVideo,
        onGallery: _pickGallery,
      ),
    );
  }

  Future<void> _takePhoto() async {
    Navigator.pop(context);
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );
    if (photo == null || !mounted) return;
    _snack('📷  ${photo.name}');
  }

  Future<void> _takeVideo() async {
    Navigator.pop(context);
    final video = await _picker.pickVideo(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (video == null || !mounted) return;
    _snack('🎥  ${video.name}');
  }

  Future<void> _pickGallery() async {
    Navigator.pop(context);
    final media = await _picker.pickMultipleMedia();
    if (media.isEmpty || !mounted) return;
    final n = media.length;
    _snack('$n fichier${n > 1 ? 's' : ''} sélectionné${n > 1 ? 's' : ''}');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: CType.body(size: 13, color: Colors.white)),
        backgroundColor: CColors.tealDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        onFabTap: _showAddSheet,
      ),
    );
  }
}

// ── Add-media picker sheet ────────────────────────────────────────────────────

class _AddSheet extends StatelessWidget {
  final VoidCallback onPhoto;
  final VoidCallback onVideo;
  final VoidCallback onGallery;

  const _AddSheet({
    required this.onPhoto,
    required this.onVideo,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
          child: Row(
            children: [
              Text('Ajouter un média',
                  style: CType.serifDisplay(size: 22, color: CColors.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
        ),
        _MediaOption(
          icon: LucideIcons.camera,
          label: 'Prendre une photo',
          sub: 'Caméra arrière',
          onTap: onPhoto,
          topBorder: true,
        ),
        _MediaOption(
          icon: LucideIcons.video,
          label: 'Enregistrer une vidéo',
          sub: 'Caméra arrière',
          onTap: onVideo,
        ),
        _MediaOption(
          icon: LucideIcons.upload,
          label: 'Importer depuis la galerie',
          sub: 'Photos et vidéos',
          onTap: onGallery,
          bottomBorder: true,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MediaOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool topBorder;
  final bool bottomBorder;

  const _MediaOption({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.topBorder = false,
    this.bottomBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: CColors.white,
          border: Border(
            left: const BorderSide(color: CColors.tealLine, width: 1),
            right: const BorderSide(color: CColors.tealLine, width: 1),
            top: BorderSide(
                color: topBorder ? CColors.tealLine : CColors.tealLineSoft,
                width: 1),
            bottom: BorderSide(
                color: bottomBorder ? CColors.tealLine : CColors.tealLineSoft,
                width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              color: CColors.tealBg,
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: CColors.tealDark),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: CType.serifDisplay(size: 17)),
                  const SizedBox(height: 2),
                  Text(sub, style: CType.body(size: 11, color: CColors.grey)),
                ],
              ),
            ),
            Text('→',
                style: CType.body(
                    size: 16, color: CColors.tealDark, w: FontWeight.w300)),
          ],
        ),
      ),
    );
  }
}