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
    final lang = localeNotifier.value.languageCode;
    final fr = lang == 'fr';

    if (!_isLogin) {
      if (_passCtrl.text != _confirmCtrl.text) {
        setState(() => _errorMsg = fr
            ? 'Les mots de passe ne correspondent pas'
            : 'Passwords do not match');
        return;
      }
    }

    setState(() { _loadingEmail = true; _errorMsg = null; });
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

  void _showForgotSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _ForgotSheet(),
      ),
    );
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
                      style: CType.body(size: 13, color: palette(context).inkSoft),
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
                          onTap: () => _showForgotSheet(context),
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
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _mode = _isLogin ? 'register' : 'login'),
                        child: Text.rich(
                          TextSpan(
                            style: CType.body(size: 13, color: palette(context).inkSoft),
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
                  style: CType.serifDisplay(size: 20, color: palette(context).ink)),
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

// ── Forgot password sheet (2-step: email → OTP + new password) ───────────────

class _ForgotSheet extends StatefulWidget {
  @override
  State<_ForgotSheet> createState() => _ForgotSheetState();
}

class _ForgotSheetState extends State<_ForgotSheet> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  final _passCtrl  = TextEditingController();
  int     _step    = 1;
  bool    _loading = false;
  String? _error;
  String  _emailSent = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final result = await AuthService.forgotPassword(email);
    if (!mounted) return;
    if (result == ForgotResult.ok) {
      _emailSent = email;
      setState(() { _loading = false; _step = 2; });
    } else {
      setState(() {
        _loading = false;
        _error = result == ForgotResult.networkError
            ? 'Impossible de joindre le serveur'
            : 'Une erreur est survenue';
      });
    }
  }

  Future<void> _resetPassword() async {
    final otp  = _otpCtrl.text.trim();
    final pass = _passCtrl.text;
    if (otp.isEmpty || pass.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final lang   = localeNotifier.value.languageCode;
    final result = await AuthService.resetPassword(_emailSent, otp, pass);
    if (!mounted) return;
    if (result == ResetResult.ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Mot de passe réinitialisé — connectez-vous',
            style: CType.body(size: 13, color: Colors.white)),
        backgroundColor: CColors.tealDark,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      setState(() { _loading = false; _error = result.message(lang); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
          child: Row(
            children: [
              Text(
                _step == 1 ? 'Mot de passe oublié' : 'Nouveau mot de passe',
                style: CType.serifDisplay(size: 22, color: p.ink),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
        ),
        const HairLine(color: CColors.tealLine),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          child: _step == 1 ? _buildStep1(p) : _buildStep2(p),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStep1(CoastPalette p) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Entrez votre adresse email — nous vous enverrons un code de vérification.',
          style: CType.body(size: 13, color: p.inkSoft)),
      const SizedBox(height: 18),
      CustomTextField(
        label: 'Email', hint: 'vous@email.com',
        controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
      ),
      if (_error != null) ...[
        const SizedBox(height: 12),
        Text(_error!, style: CType.body(size: 12, color: CColors.redInk)),
      ],
      const SizedBox(height: 20),
      GestureDetector(
        onTap: _loading ? null : _sendOtp,
        child: Container(
          height: 52, color: CColors.tealDark, alignment: Alignment.center,
          child: _loading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : Text('Envoyer le code',
                  style: CType.eyebrow(size: 11, tracking: 0.22, color: Colors.white)),
        ),
      ),
    ],
  );

  Widget _buildStep2(CoastPalette p) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Entrez le code reçu par email et choisissez un nouveau mot de passe.',
          style: CType.body(size: 13, color: p.inkSoft)),
      const SizedBox(height: 18),
      CustomTextField(
        label: 'Code de vérification', hint: '123456',
        controller: _otpCtrl, keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 14),
      CustomTextField(
        label: 'Nouveau mot de passe', hint: '••••••••',
        controller: _passCtrl, isPassword: true,
      ),
      if (_error != null) ...[
        const SizedBox(height: 12),
        Text(_error!, style: CType.body(size: 12, color: CColors.redInk)),
      ],
      const SizedBox(height: 20),
      GestureDetector(
        onTap: _loading ? null : _resetPassword,
        child: Container(
          height: 52, color: CColors.tealDark, alignment: Alignment.center,
          child: _loading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : Text('Confirmer',
                  style: CType.eyebrow(size: 11, tracking: 0.22, color: Colors.white)),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: _loading ? null : () => setState(() { _step = 1; _error = null; }),
        child: Center(
          child: Text('Renvoyer un code',
              style: CType.body(size: 12, color: CColors.tealDark)),
        ),
      ),
    ],
  );
}