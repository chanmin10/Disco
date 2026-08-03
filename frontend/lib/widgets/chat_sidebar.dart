import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme.dart' as theme_model;
import '../providers/translation_provider.dart';
import 'swipe_to_delete.dart';

const _kBorderColor = Color(0x14000000); // rgba(0,0,0,0.08)

class ChatSidebar extends ConsumerWidget {
  const ChatSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themesAsync = ref.watch(themesProvider);
    final selectedId = ref.watch(selectedThemeProvider);
    final hiddenIds = ref.watch(hiddenThemeIdsProvider);

    return Container(
      color: const Color(0xFFF5F5F7),
      child: Column(
        children: [
          Expanded(
            child: themesAsync.when(
              data: (themes) => ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  for (final theme in themes)
                    if (!hiddenIds.contains(theme.id))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: SwipeToDelete(
                          key: ValueKey(theme.id),
                          borderRadius: BorderRadius.circular(7),
                          onDelete: () {
                            ref.read(hiddenThemeIdsProvider.notifier).update(
                                  (ids) => {...ids, theme.id},
                                );
                            if (selectedId == theme.id) {
                              ref.read(selectedThemeProvider.notifier).state = null;
                            }
                            ref.read(apiServiceProvider).deleteTheme(theme.id).then((_) {
                              ref.invalidate(themesProvider);
                              ref.read(hiddenThemeIdsProvider.notifier).update(
                                    (ids) => {...ids}..remove(theme.id),
                                  );
                            });
                          },
                          child: _ThemeRow(
                            theme: theme,
                            isActive: theme.id == selectedId,
                            onTap: () {
                              ref.read(selectedThemeProvider.notifier).state = theme.id;
                              ref.read(newThemePickerOpenProvider.notifier).state = false;
                            },
                          ),
                        ),
                      ),
                ],
              ),
              loading: () => const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (err, st) => const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '테마를 불러오지 못했어요',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9A9AA0)),
                ),
              ),
            ),
          ),
          const _NewThemeButton(),
        ],
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final theme_model.Theme theme;
  final bool isActive;
  final VoidCallback onTap;

  const _ThemeRow({required this.theme, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0A84FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            theme.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? Colors.white : const Color(0xFF1D1D1F),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _NewThemeButton extends ConsumerWidget {
  const _NewThemeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kBorderColor)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(newThemePickerOpenProvider.notifier).state =
                !ref.read(newThemePickerOpenProvider);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, size: 15, color: Color(0xFFA1A1A6)),
                SizedBox(width: 8),
                Text(
                  '새 채팅방',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA1A1A6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _kLanguageOptions = [
  ('en', 'English'),
  ('ja', 'Japanese'),
  ('zh', 'Chinese'),
  ('es', 'Spanish'),
  ('fr', 'French'),
];

/// The new-theme creation popover. Rendered by [MainScreen] as a screen-level
/// overlay so it can sit above the whole window and close on outside taps.
class NewThemePopover extends ConsumerStatefulWidget {
  const NewThemePopover({super.key});

  @override
  ConsumerState<NewThemePopover> createState() => _NewThemePopoverState();
}

class _NewThemePopoverState extends ConsumerState<NewThemePopover> {
  final TextEditingController _nameController = TextEditingController();
  String _targetLanguage = _kLanguageOptions.first.$1;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    try {
      final api = ref.read(apiServiceProvider);
      final theme = await api.createTheme(name, _targetLanguage);
      ref.invalidate(themesProvider);
      ref.read(selectedThemeProvider.notifier).state = theme.id;
      ref.read(newThemePickerOpenProvider.notifier).state = false;
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                isDense: true,
                hintText: '채팅방 이름',
                hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9A9AA0)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _targetLanguage,
              isDense: true,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF1D1D1F)),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                ),
              ),
              items: [
                for (final option in _kLanguageOptions)
                  DropdownMenuItem(value: option.$1, child: Text(option.$2)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _targetLanguage = value);
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A84FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              child: Text(_submitting ? '생성 중...' : '만들기'),
            ),
          ],
        ),
      ),
    );
  }
}
