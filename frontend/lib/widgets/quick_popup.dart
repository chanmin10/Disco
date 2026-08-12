import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/theme.dart' as theme_model;
import '../providers/popup_provider.dart';
import '../providers/translation_provider.dart';
import '../services/popup_window_service.dart';
import 'bold_markdown_text.dart';
import 'segmented_control.dart';

/// The floating always-on-top card shown by the Shift+Option+Space global
/// hotkey. See design/DISCO_MVP_DESIGN/Popup Window.dc.html for the
/// reference mockup.
class QuickPopup extends ConsumerStatefulWidget {
  const QuickPopup({super.key});

  @override
  ConsumerState<QuickPopup> createState() => _QuickPopupState();
}

class _QuickPopupState extends ConsumerState<QuickPopup> {
  final _controller = TextEditingController();
  final _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The popup now boots as its own window/engine with a fresh provider
      // container each time it opens, so there's no stale state from a prior
      // session to clear — this just resolves the default target theme.
      // Deferred to after the first frame: calling this during initState
      // modifies popupControllerProvider while the widget tree (including
      // this same subtree's first build) is still in progress, which
      // Riverpod rejects.
      ref.read(popupControllerProvider.notifier).reset();
      _inputFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _toggleEngine() {
    final current = ref.read(engineProvider);
    ref.read(engineProvider.notifier).state = current == 'quick' ? 'general' : 'quick';
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          popupSelfWindow.close();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          // In-app only: flips General/Quick while the popup itself is
          // focused (i.e. while the user is typing into it), not a global
          // shortcut like the Shift+Option+Space hotkey.
          _toggleEngine();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Material(
        color: Colors.transparent,
        // The window's *current* height is often smaller than the card's
        // natural content height (e.g. right after a long AI response comes
        // in, before syncSize has resized the window). A plain Align would
        // cap the card at that stale height and overflow. OverflowBox lets
        // the card measure/paint at its true natural size regardless of the
        // ambient constraint; _syncWindowSize then grows the window to match.
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minWidth: 0,
          maxWidth: double.infinity,
          minHeight: 0,
          maxHeight: double.infinity,
          child: _PopupCard(controller: _controller, inputFocusNode: _inputFocusNode),
        ),
      ),
    );
  }
}

class _PopupCard extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode inputFocusNode;
  const _PopupCard({required this.controller, required this.inputFocusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(popupControllerProvider);
    final notifier = ref.read(popupControllerProvider.notifier);
    final themes = ref.watch(themesProvider).valueOrNull ?? const [];

    String targetRoomName = '테마 없음';
    for (final t in themes) {
      if (t.id == state.themeId) {
        targetRoomName = t.name;
        break;
      }
    }

    // Scheduled on every rebuild of this widget (i.e. every time the popup's
    // state actually changes — new result, dropdown toggled, etc.), unlike
    // the parent QuickPopup which only builds once. That's what makes the
    // window actually grow when a later, taller response comes in instead
    // of just matching whatever height the popup happened to open at.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      popupSelfWindow.syncSize(box.size.height);
    });

    return Container(
      width: kPopupBaseSize.width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InputRow(controller: controller, focusNode: inputFocusNode),
              Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: Colors.black.withValues(alpha: 0.08)),
              _ResultRow(
                state: state,
                targetRoomName: targetRoomName,
                themes: themes,
                onToggleDropdown: notifier.toggleDropdown,
                onPickTheme: notifier.selectTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputRow extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  const _InputRow({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(engineProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          const Icon(Icons.public, size: 20, color: Color(0xFFC7C7CC)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: () => ref.read(popupControllerProvider.notifier).closeDropdown(),
              onChanged: (v) => ref.read(popupControllerProvider.notifier).setText(v),
              // Without this, TextField's default onEditingComplete handler
              // for TextInputAction.done calls focusNode.unfocus() right
              // after onSubmitted fires — that's what made typing seem to
              // "lock up" after pressing Enter. A no-op here keeps focus.
              onEditingComplete: () {},
              onSubmitted: (value) {
                // While a request is already in flight, Enter should be a
                // total no-op — including not clearing what's typed, since
                // nothing was actually submitted.
                if (ref.read(popupControllerProvider).loading) return;
                // Clear first: TextEditingController.clear() synchronously
                // fires onChanged -> setText(''), which would otherwise
                // stomp the loading:true that submit() sets right after.
                controller.clear();
                ref.read(popupControllerProvider.notifier).submit(value);
              },
              style: const TextStyle(fontSize: 18, color: Color(0xFF1D1D1F)),
              decoration: const InputDecoration(
                hintText: '번역할 텍스트 입력',
                hintStyle: TextStyle(color: Color(0xFF8A8A92)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SegmentedControl(
            value: engine,
            onChanged: (v) => ref.read(engineProvider.notifier).state = v,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final PopupState state;
  final String targetRoomName;
  final List<theme_model.Theme> themes;
  final VoidCallback onToggleDropdown;
  final ValueChanged<String> onPickTheme;

  const _ResultRow({
    required this.state,
    required this.targetRoomName,
    required this.themes,
    required this.onToggleDropdown,
    required this.onPickTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: state.loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF9A9AA0)),
                      )
                    : state.resultText != null
                        ? Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              BoldMarkdownText(
                                state.resultText!,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1D1D1F)),
                              ),
                              if (state.saved) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check_circle, size: 12, color: Color(0xFF34C759)),
                                const SizedBox(width: 3),
                                const Text('저장됨', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF34C759))),
                              ],
                            ],
                          )
                        : const Text(
                            '번역 결과가 여기에 표시됩니다',
                            style: TextStyle(fontSize: 13, color: Color(0xFFB0B0B6)),
                          ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _RoomDropdown(
            targetRoomName: targetRoomName,
            themes: themes,
            open: state.dropdownOpen,
            selectedThemeId: state.themeId,
            onToggle: onToggleDropdown,
            onPick: onPickTheme,
          ),
        ],
      ),
    );
  }
}

const double _kDropdownWidth = 140;

/// Renders the room list in the app's [Overlay] rather than in-flow below
/// the trigger pill. It's positioned via a [LayerLink] so it still tracks
/// the pill's location, but — critically — it's no longer part of the tree
/// [_PopupCard] measures for [PopupWindowService.syncSize]. Opening/closing
/// it must not change the popup window's height.
class _RoomDropdown extends StatefulWidget {
  final String targetRoomName;
  final List<theme_model.Theme> themes;
  final bool open;
  final String? selectedThemeId;
  final VoidCallback onToggle;
  final ValueChanged<String> onPick;

  const _RoomDropdown({
    required this.targetRoomName,
    required this.themes,
    required this.open,
    required this.selectedThemeId,
    required this.onToggle,
    required this.onPick,
  });

  @override
  State<_RoomDropdown> createState() => _RoomDropdownState();
}

class _RoomDropdownState extends State<_RoomDropdown> {
  final _link = LayerLink();
  OverlayEntry? _entry;

  @override
  void didUpdateWidget(covariant _RoomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Overlay.insert()/remove() both call markNeedsBuild() on the Overlay,
    // an ancestor that's already mid-build during didUpdateWidget — doing
    // that synchronously here throws "setState() or markNeedsBuild() called
    // during build". Deferring to a post-frame callback fixes it; reading
    // `widget.open` inside the callback (rather than capturing it now)
    // means it still reflects whatever the latest build actually settled on.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.open) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay() {
    _removeOverlay();
    _entry = OverlayEntry(
      builder: (context) => Positioned(
        width: _kDropdownWidth,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 8),
          child: _RoomList(
            themes: widget.themes,
            selectedThemeId: widget.selectedThemeId,
            onPick: widget.onPick,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.targetRoomName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F))),
              const SizedBox(width: 5),
              const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF86868B)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  final List<theme_model.Theme> themes;
  final String? selectedThemeId;
  final ValueChanged<String> onPick;

  const _RoomList({required this.themes, required this.selectedThemeId, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _kDropdownWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 26)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // Stretch so each row's tap target and highlight fill the full
          // dropdown width instead of just wrapping the label text.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final t in themes)
              Material(
                color: t.id == selectedThemeId ? Colors.black.withValues(alpha: 0.045) : Colors.transparent,
                child: InkWell(
                  onTap: () => onPick(t.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      t.name,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF1D1D1F)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
