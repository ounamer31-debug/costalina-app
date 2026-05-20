import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../main.dart' show localeNotifier;
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hair_line.dart';

/// Costalina AI assistant — multi-turn chat with the Gemini-backed /api/ai/chat endpoint.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _Message {
  final String role; // 'user' | 'assistant'
  final String content;
  _Message(this.role, this.content);
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Message> _msgs = [];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _msgs.add(_Message('assistant',
        "Bonjour ! Je suis l'assistant Costalina. Je peux t'expliquer comment signaler un problème sur une plage, "
        "comment fonctionne le système de points, ou te parler de l'érosion côtière en Tunisie. Que veux-tu savoir ?"));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _msgs.add(_Message('user', text));
      _ctrl.clear();
      _sending = true;
    });
    _scrollToEnd();

    final reply = await ApiService.aiChat(
      _msgs.map((m) => {'role': m.role, 'content': m.content}).toList(),
      lang: localeNotifier.value.languageCode,
    );

    if (!mounted) return;
    setState(() {
      _msgs.add(_Message('assistant',
          reply ?? "Désolé, je n'arrive pas à répondre pour le moment."));
      _sending = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CColors.tealLineSoft)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.arrowLeft, size: 20, color: CColors.tealDark),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(
                      color: CColors.tealBg, shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(LucideIcons.sparkles, size: 14, color: CColors.tealDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Assistant Costalina',
                            style: CType.serifDisplay(size: 17, color: p.ink)),
                        Text('Propulsé par l\'IA',
                            style: CType.body(size: 11, color: p.inkSoft)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                itemCount: _msgs.length + (_sending ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _msgs.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: _TypingDots(),
                    );
                  }
                  return _Bubble(message: _msgs[i]);
                },
              ),
            ),
            // Input
            const HairLine(color: CColors.tealLineSoft),
            Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14,
                  8 + MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: p.surface,
                        border: Border.all(color: CColors.tealLine),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Pose ta question…',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: CType.body(size: 14, color: p.ink),
                        maxLines: 4,
                        minLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: Container(
                      width: 48, height: 48,
                      color: _sending ? CColors.grey : CColors.tealDark,
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.send, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Message message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 26, height: 26,
              decoration: const BoxDecoration(
                color: CColors.tealBg, shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.sparkles, size: 12, color: CColors.tealDark),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color:  isUser ? CColors.tealDark : p.surface,
                border: Border.all(
                    color: isUser ? CColors.tealDark : CColors.tealLine),
              ),
              child: Text(
                message.content,
                style: CType.body(
                  size: 13,
                  color: isUser ? Colors.white : p.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_c.value + i / 3) % 1.0;
            final scale = 0.5 + 0.5 * (1 - (t - 0.5).abs() * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: CColors.tealDark.withValues(alpha: scale),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}