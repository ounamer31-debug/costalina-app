import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_strings.dart';
import '../main.dart' show localeNotifier;
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/costalina_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/eyebrow.dart';
import '../widgets/hair_line.dart';
import '../widgets/serif_title.dart';

class LoginScreen extends StatefulWidget {
  final String initialMode;
  const LoginScreen({super.key, this.initialMode = 'login'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _mode;
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _loadingSocial; // 'google' | 'apple' | null
  bool _loadingEmail = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    localeNotifier.addListener(_onLocale);
  }

  void _onLocale() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    localeNotifier.removeListener(_onLocale);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _isLogin => _mode == 'login';

  Future<void> _submit() async {
    if (_loadingEmail) return;
    setState(() { _loadingEmail = true; _errorMsg = null; });
    final lang = localeNotifier.value.languageCode;
    final result = _isLogin
        ? await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text)
        : await AuthService.register(
            _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (result.success) {
      Navigator.pushReplacementNamed(context, '/app');
    } else {
      setState(() { _loadingEmail = false; _errorMsg = result.message(lang); });
    }
  }

  Future<void> _signInWith(String provider) async {
    // Social sign-in not available without Firebase Auth
    // Show a friendly message instead
    setState(() => _errorMsg = 'Utilisez email + mot de passe pour vous connecter.');
  }

  void _showLanguagePicker() {
    final s = AppStrings.current;
    showModalBottomSheet(
      context: context,
      backgroundColor: CColors.sand,
      shape: const RoundedRectangleBorder(),
      builder: (_) => _LanguageSheet(title: s.chooseLanguage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return Scaffold(
      backgroundColor: CColors.sand,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Branding header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 48, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CostalinaLogo(size: 48),
                        const Spacer(),
                        // Language picker button
                        GestureDetector(
                          onTap: _showLanguagePicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: CColors.tealLine, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.globe, size: 13, color: CColors.tealDark),
                                const SizedBox(width: 6),
                                Text(
                                  _currentFlag(),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SerifTitle(
                      _isLogin ? s.loginTitle : s.registerTitle,
                      italic: _isLogin ? s.loginItalic : s.registerItalic,
                      size: 32,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLogin ? s.loginSubtitle : s.registerSubtitle,
                      style: CType.body(size: 13, color: CColors.inkSoft),
                    ),
                  ],
                ),
              ),
              // ── Mode toggle ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _TabBtn(
                          label: s.tabLogin,
                          active: _isLogin,
                          onTap: () => setState(() => _mode = 'login'),
                        )),
                        Expanded(child: _TabBtn(
                          label: s.tabRegister,
                          active: !_isLogin,
                          onTap: () => setState(() => _mode = 'register'),
                        )),
                      ],
                    ),
                    const HairLine(color: CColors.tealLine),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // ── Form fields ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isLogin) ...[
                      CustomTextField(
                        label: s.labelFullName,
                        hint: s.hintFullName,
                        controller: _nameCtrl,
                      ),
                      const SizedBox(height: 16),
                    ],
                    CustomTextField(
                      label: s.labelEmail,
                      hint: s.hintEmail,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: s.labelPassword,
                      hint: '••••••••',
                      controller: _passCtrl,
                      isPassword: true,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: s.labelConfirmPassword,
                        hint: '••••••••',
                        controller: _confirmCtrl,
                        isPassword: true,
                      ),
                    ],
                    if (_isLogin) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            s.forgotPassword,
                            style: CType.body(size: 12, color: CColors.tealDark),
                          ),
                        ),
                      ),
                    ],
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: CColors.redBg,
                          border: Border.all(color: CColors.redInk.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Text(
                          _errorMsg!,
                          style: CType.body(size: 12, color: CColors.redInk),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _loadingEmail ? null : _submit,
                      child: Container(
                        height: 52,
                        color: CColors.tealDark,
                        alignment: Alignment.center,
                        child: _loadingEmail
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ))
                            : Text(
                                _isLogin ? s.btnLogin : s.btnRegister,
                                style: CType.eyebrow(
                                    size: 11,
                                    tracking: 0.22,
                                    color: Colors.white,
                                    w: FontWeight.w400),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: HairLine(color: CColors.tealLine)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Eyebrow(s.orDivider,
                              size: 9, tracking: 0.28, color: CColors.grey),
                        ),
                        const Expanded(child: HairLine(color: CColors.tealLine)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SocialBtn(
                      label: s.continueGoogle,
                      loading: _loadingSocial == 'google',
                      onTap: () => _signInWith('google'),
                    ),
                    const SizedBox(height: 10),
                    _SocialBtn(
                      label: s.continueApple,
                      loading: _loadingSocial == 'apple',
                      onTap: () => _signInWith('apple'),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _mode = _isLogin ? 'register' : 'login'),
                        child: Text.rich(
                          TextSpan(
                            style: CType.body(size: 13, color: CColors.inkSoft),
                            children: [
                              TextSpan(
                                text: _isLogin ? s.noAccount : s.alreadyMember,
                              ),
                              TextSpan(
                                text: _isLogin ? s.createAccount : s.signIn,
                                style: CType.body(
                                    size: 13,
                                    color: CColors.tealDark,
                                    w: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _currentFlag() {
    final code = localeNotifier.value.languageCode;
    return langOptions.firstWhere((l) => l.code == code,
        orElse: () => langOptions.first).flag;
  }
}

// ── Language picker sheet ─────────────────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  final String title;
  const _LanguageSheet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
          child: Row(
            children: [
              Text(title,
                  style: CType.serifDisplay(size: 20, color: CColors.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
        ),
        const HairLine(color: CColors.tealLine),
        for (final lang in langOptions) ...[
          _LangRow(lang: lang),
          const HairLine(color: CColors.tealLineSoft),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LangRow extends StatelessWidget {
  final LangOption lang;
  const _LangRow({required this.lang});

  @override
  Widget build(BuildContext context) {
    final isActive = localeNotifier.value.languageCode == lang.code;
    return GestureDetector(
      onTap: () {
        localeNotifier.value = Locale(lang.code);
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(lang.nativeName,
                  style: CType.serifDisplay(
                      size: 17,
                      color: isActive ? CColors.tealDark : CColors.ink)),
            ),
            if (isActive)
              const Icon(LucideIcons.check, size: 16, color: CColors.tealDark),
          ],
        ),
      ),
    );
  }
}

// ── Tab toggle button ─────────────────────────────────────────────────────────

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Eyebrow(
              label,
              size: 10,
              tracking: 0.22,
              color: active ? CColors.tealDark : CColors.grey,
              weight: active ? FontWeight.w500 : FontWeight.w400,
            ),
            const SizedBox(height: 10),
            if (active)
              Container(width: double.infinity, height: 2, color: CColors.tealDark),
          ],
        ),
      ),
    );
  }
}

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _SocialBtn({required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: CColors.white,
          border: Border.all(color: CColors.tealLine, width: 1),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(CColors.tealDark),
                ),
              )
            : Text(label, style: CType.body(size: 13, color: CColors.ink)),
      ),
    );
  }
}