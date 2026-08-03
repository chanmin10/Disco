import 'package:flutter/material.dart';

/// Wraps [child] in an iOS Mail-style swipe: swiping left reveals a red
/// delete button behind the row, and the row is only removed once that
/// button is tapped (unlike [Dismissible], a swipe alone never deletes).
class SwipeToDelete extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final double revealWidth;
  final BorderRadius borderRadius;

  const SwipeToDelete({
    super.key,
    required this.child,
    required this.onDelete,
    this.revealWidth = 60,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final next = (_controller.value - details.delta.dx / widget.revealWidth).clamp(0.0, 1.0);
    _controller.value = next;
  }

  void _onDragEnd(DragEndDetails details) {
    _controller.animateTo(_controller.value > 0.5 ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: widget.revealWidth,
                child: Material(
                  color: const Color(0xFFFF3B30),
                  child: InkWell(
                    onTap: widget.onDelete,
                    child: const Center(
                      child: Icon(Icons.delete, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(-widget.revealWidth * _controller.value, 0),
              child: child,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
