import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translation_provider.dart';

class VocabSidebar extends ConsumerWidget {
  const VocabSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocab = ref.watch(vocabListProvider);

    return Container(
      color: const Color(0xFFFAFAFA),
      child: vocab.isEmpty ? const _EmptyVocabState() : _VocabList(vocab: vocab),
    );
  }
}

class _VocabList extends StatelessWidget {
  final List vocab;
  const _VocabList({required this.vocab});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final item in vocab)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: _VocabFlipCard(item: item),
          ),
      ],
    );
  }
}

class _VocabFlipCard extends StatefulWidget {
  final dynamic item;
  const _VocabFlipCard({required this.item});

  @override
  State<_VocabFlipCard> createState() => _VocabFlipCardState();
}

class _VocabFlipCardState extends State<_VocabFlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_controller.value == 0) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final isBackVisible = _controller.value > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: isBackVisible
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _Face(
                      text: item.sub,
                      background: const Color(0xFF0A84FF),
                      textColor: Colors.white,
                      fontSize: 12,
                    ),
                  )
                : _Face(
                    text: item.word,
                    background: item.isNew ? const Color(0x1C0A84FF) : Colors.white,
                    textColor: const Color(0xFF1D1D1F),
                    fontSize: 12.5,
                  ),
          );
        },
      ),
    );
  }
}

class _Face extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final double fontSize;

  const _Face({
    required this.text,
    required this.background,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}

class _EmptyVocabState extends StatelessWidget {
  const _EmptyVocabState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border, size: 24, color: Color(0xFFC9C9CE)),
            const SizedBox(height: 14),
            const Text(
              '아직 저장된 단어가 없어요',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3A3A3C)),
            ),
            const SizedBox(height: 6),
            const Text(
              '채팅에서 번역한 단어가\n자동으로 여기 쌓여요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF9A9AA0), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
