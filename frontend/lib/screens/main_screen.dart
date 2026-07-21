import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/vocab_item.dart';
import '../providers/translation_provider.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/vocab_sidebar.dart';
import '../widgets/segmented_control.dart';

const _kBorderColor = Color(0x14000000); // rgba(0,0,0,0.08)
const _kAccent = Color(0xFF0A84FF);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _inputFocused = false;

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(() {
      setState(() => _inputFocused = _inputFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || ref.read(isLoadingProvider)) return;

    final roomId = ref.read(selectedThemeProvider);
    final engine = ref.read(engineProvider);
    final notifier = ref.read(roomsProvider.notifier);
    final api = ref.read(apiServiceProvider);

    notifier.addMessage(
      roomId,
      ChatMessage(id: 'u${DateTime.now().microsecondsSinceEpoch}', role: 'user', text: text),
    );
    _inputController.clear();
    ref.read(inputProvider.notifier).state = '';
    ref.read(isLoadingProvider.notifier).state = true;
    _scrollToBottom();

    try {
      String translated;
      if (engine == 'quick') {
        final res = await api.translateQuick(roomId, text);
        ref.read(translationProvider.notifier).state = res;
        translated = res.wordTarget;
      } else {
        final res = await api.translateLLM(roomId, text);
        translated = res.text;
      }

      notifier.addMessage(
        roomId,
        ChatMessage(id: 'b${DateTime.now().microsecondsSinceEpoch}', role: 'bot', text: translated),
      );

      final classified = await api.classify(roomId, text, translated);
      if (classified.isVocab) {
        final vocabId = 'v${DateTime.now().microsecondsSinceEpoch}';
        notifier.addVocab(
          roomId,
          VocabItem(id: vocabId, word: translated, sub: text, isNew: true),
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          notifier.clearVocabNew(roomId, vocabId);
        });
      }
    } catch (_) {
      notifier.addMessage(
        roomId,
        ChatMessage(
          id: 'e${DateTime.now().microsecondsSinceEpoch}',
          role: 'bot',
          text: '번역 중 오류가 발생했어요. 다시 시도해주세요.',
        ),
      );
    } finally {
      if (mounted) ref.read(isLoadingProvider.notifier).state = false;
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatProvider, (prev, next) => _scrollToBottom());
    ref.listen(selectedThemeProvider, (prev, next) => _scrollToBottom());

    final pickerOpen = ref.watch(newRoomPickerOpenProvider);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            ref.read(newRoomPickerOpenProvider)) {
          ref.read(newRoomPickerOpenProvider.notifier).state = false;
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                _TitleBar(inputFocusNode: _inputFocusNode),
                Expanded(
                  child: Row(
                    children: [
                      _AnimatedSidebar(
                        open: ref.watch(isLeftSidebarOpen),
                        width: 160,
                        borderSide: _kBorderColor,
                        isLeftBorder: false,
                        child: const ChatSidebar(),
                      ),
                      Expanded(child: _ChatArea(
                        inputController: _inputController,
                        inputFocusNode: _inputFocusNode,
                        inputFocused: _inputFocused,
                        scrollController: _scrollController,
                        onSend: _sendMessage,
                      )),
                      _AnimatedSidebar(
                        open: ref.watch(isRightSidebarOpen),
                        width: 200,
                        borderSide: _kBorderColor,
                        isLeftBorder: true,
                        child: const VocabSidebar(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (pickerOpen) ...[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ref.read(newRoomPickerOpenProvider.notifier).state = false,
                  child: const SizedBox.expand(),
                ),
              ),
              const Positioned(
                left: 8,
                width: 144,
                bottom: 44,
                child: NewRoomPopover(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedSidebar extends StatelessWidget {
  final bool open;
  final double width;
  final Color borderSide;
  final bool isLeftBorder; // true = border on the left edge, false = right edge
  final Widget child;

  const _AnimatedSidebar({
    required this.open,
    required this.width,
    required this.borderSide,
    required this.isLeftBorder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: open ? width : 0,
      decoration: BoxDecoration(
        border: Border(
          left: isLeftBorder && open ? BorderSide(color: borderSide) : BorderSide.none,
          right: !isLeftBorder && open ? BorderSide(color: borderSide) : BorderSide.none,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: width,
        maxWidth: width,
        child: SizedBox(width: width, child: child),
      ),
    );
  }
}

class _TitleBar extends ConsumerWidget {
  final FocusNode inputFocusNode;
  const _TitleBar({required this.inputFocusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRoom = ref.watch(activeRoomProvider);
    final engine = ref.watch(engineProvider);
    final rightSidebarOpen = ref.watch(isRightSidebarOpen);

    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F8),
        border: Border(bottom: BorderSide(color: _kBorderColor)),
      ),
      child: Row(
        children: [
          // Reserved to align with the left sidebar's width below; the real
          // traffic lights are drawn by the native macOS titlebar above this.
          const SizedBox(
            width: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: _kBorderColor)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _SidebarToggleButton(
                    isLeft: true,
                    onTap: () {
                      final notifier = ref.read(isLeftSidebarOpen.notifier);
                      notifier.state = !notifier.state;
                    },
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      activeRoom.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SegmentedControl(
                    value: engine,
                    onChanged: (v) => ref.read(engineProvider.notifier).state = v,
                  ),
                  const SizedBox(width: 10),
                  _SidebarToggleButton(
                    isLeft: false,
                    onTap: () {
                      final notifier = ref.read(isRightSidebarOpen.notifier);
                      notifier.state = !notifier.state;
                    },
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: rightSidebarOpen ? 200 : 0,
            padding: EdgeInsets.only(left: rightSidebarOpen ? 16 : 0),
            decoration: BoxDecoration(
              border: Border(
                left: rightSidebarOpen ? const BorderSide(color: _kBorderColor) : BorderSide.none,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '단어장',
                overflow: TextOverflow.clip,
                softWrap: false,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6E6E73)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  final bool isLeft;
  final VoidCallback onTap;
  const _SidebarToggleButton({required this.isLeft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: CustomPaint(
              size: const Size(16, 14),
              painter: _SidebarIconPainter(isLeft: isLeft),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarIconPainter extends CustomPainter {
  final bool isLeft;
  const _SidebarIconPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF6E6E73)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final outer = RRect.fromRectAndRadius(
      const Rect.fromLTWH(1, 1, 14, 12),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(outer, stroke);

    final dividerX = isLeft ? 5.5 : 10.5;
    canvas.drawLine(Offset(dividerX, 1.3), Offset(dividerX, 12.7), stroke);

    final fillX = isLeft ? 1.8 : 11.2;
    final fill = Paint()..color = const Color(0xFF6E6E73).withValues(alpha: 0.55);
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(fillX, 1.8, 3, 10.4),
      const Radius.circular(1),
    );
    canvas.drawRRect(fillRect, fill);
  }

  @override
  bool shouldRepaint(covariant _SidebarIconPainter oldDelegate) => oldDelegate.isLeft != isLeft;
}

class _ChatArea extends ConsumerWidget {
  final TextEditingController inputController;
  final FocusNode inputFocusNode;
  final bool inputFocused;
  final ScrollController scrollController;
  final VoidCallback onSend;

  const _ChatArea({
    required this.inputController,
    required this.inputFocusNode,
    required this.inputFocused,
    required this.scrollController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final input = ref.watch(inputProvider);
    final canSend = input.trim().isNotEmpty && !isLoading;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final msg in messages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MessageBubble(message: msg, maxWidth: constraints.maxWidth * 0.7),
                      ),
                    if (isLoading) const _TypingIndicator(),
                  ],
                );
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _kBorderColor)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    focusNode: inputFocusNode,
                    onChanged: (v) => ref.read(inputProvider.notifier).state = v,
                    onSubmitted: (_) => onSend(),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1F)),
                    decoration: InputDecoration(
                      hintText: '번역할 텍스트 입력',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9A9AA0)),
                      filled: true,
                      fillColor: inputFocused ? Colors.white : const Color(0xFFF5F5F7),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(color: _kAccent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: canSend ? onSend : null,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: canSend ? 1 : 0.35,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(color: _kAccent, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final double maxWidth;
  const _MessageBubble({required this.message, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isUser ? _kAccent : const Color(0xFFF0F0F2),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: Radius.circular(isUser ? 15 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 15),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isUser ? Colors.white : const Color(0xFF1D1D1F),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _pulse(double t) {
    if (t < 0.4) return t / 0.4;
    if (t < 0.8) return 1 - (t - 0.4) / 0.4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F2),
            borderRadius: BorderRadius.circular(15).copyWith(bottomLeft: const Radius.circular(4)),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final offset in [0.0, 0.136, 0.273]) ...[
                    if (offset != 0.0) const SizedBox(width: 4),
                    Builder(builder: (context) {
                      final t = (_controller.value + offset) % 1.0;
                      final p = _pulse(t);
                      return Transform.translate(
                        offset: Offset(0, -2 * p),
                        child: Opacity(
                          opacity: 0.25 + 0.75 * p,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9A9AA0),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
