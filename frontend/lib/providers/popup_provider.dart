import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'translation_provider.dart';
import '../models/chat_message.dart';

/// Whether the single native window is currently showing the global-hotkey
/// popup instead of the main chat UI. [PopupWindowService] flips this after
/// it finishes resizing/repositioning the OS window.
final isPopupWindowProvider = StateProvider<bool>((ref) => false);

class PopupState {
  final String text;
  final String? resultText;
  final bool saved;
  final bool loading;
  final bool dropdownOpen;
  final String? themeId;

  const PopupState({
    this.text = '',
    this.resultText,
    this.saved = false,
    this.loading = false,
    this.dropdownOpen = false,
    this.themeId,
  });

  PopupState copyWith({
    String? text,
    String? resultText,
    bool? saved,
    bool? loading,
    bool? dropdownOpen,
    String? themeId,
  }) {
    return PopupState(
      text: text ?? this.text,
      resultText: resultText ?? this.resultText,
      saved: saved ?? this.saved,
      loading: loading ?? this.loading,
      dropdownOpen: dropdownOpen ?? this.dropdownOpen,
      themeId: themeId ?? this.themeId,
    );
  }
}

class PopupController extends StateNotifier<PopupState> {
  PopupController(this._ref) : super(const PopupState());
  final Ref _ref;

  /// Clears the popup back to a blank slate, defaulting the target room to
  /// whichever theme is currently active in the main window.
  void reset() {
    final activeTheme = _ref.read(activeThemeProvider);
    state = PopupState(themeId: activeTheme?.id);
  }

  void setText(String text) {
    if (text.trim().isEmpty) {
      // Fresh PopupState (not copyWith) so the stale result/saved badge from
      // the previous query doesn't linger once the input is cleared.
      state = PopupState(text: text, themeId: state.themeId);
    } else {
      state = state.copyWith(text: text, saved: false);
    }
  }

  void toggleDropdown() {
    state = state.copyWith(dropdownOpen: !state.dropdownOpen);
  }

  void closeDropdown() {
    if (state.dropdownOpen) state = state.copyWith(dropdownOpen: false);
  }

  void selectTheme(String themeId) {
    state = state.copyWith(themeId: themeId, dropdownOpen: false);
  }

  /// Takes the just-typed text directly (rather than reading `state.text`)
  /// so the caller can clear the input field in the same tick without racing
  /// the TextField's own onChanged-triggered [setText] reset.
  Future<void> submit(String rawText) async {
    final text = rawText.trim();
    final themeId = state.themeId;
    if (text.isEmpty || themeId == null || state.loading) return;

    final engine = _ref.read(engineProvider);
    final api = _ref.read(apiServiceProvider);
    final chatNotifier = _ref.read(chatProvider.notifier);
    final vocabNotifier = _ref.read(vocabListProvider.notifier);

    // Fresh PopupState so the previous result/saved badge doesn't flash
    // while the new request is in flight, and the input is left blank and
    // ready for the next phrase instead of showing what was just submitted.
    state = PopupState(themeId: themeId, loading: true);
    chatNotifier.addMessage(
      themeId,
      ChatMessage(id: 'u${DateTime.now().microsecondsSinceEpoch}', role: 'user', text: text),
    );

    try {
      if (engine == 'quick') {
        // Quick mode: Google Translate, then classify separately — /translate/quick
        // never persists a word itself, so classify is what may save it.
        final res = await api.translateQuick(themeId, text);
        chatNotifier.addMessage(
          themeId,
          ChatMessage(id: 'b${DateTime.now().microsecondsSinceEpoch}', role: 'bot', text: res.response),
        );
        state = state.copyWith(resultText: res.response, loading: false);

        final classified = await api.classify(themeId, res.textNative, res.textTarget);
        if (classified.isVocab) {
          await vocabNotifier.refresh(themeId);
          state = state.copyWith(saved: true);
        }
      } else {
        // AI mode: /translate/ai already saves the word internally, so classify
        // must NOT be called here — that would double-save.
        final res = await api.translateAi(themeId, text);
        chatNotifier.addMessage(
          themeId,
          ChatMessage(id: 'b${DateTime.now().microsecondsSinceEpoch}', role: 'bot', text: res.text),
        );
        await vocabNotifier.refresh(themeId);
        state = state.copyWith(resultText: res.text, loading: false, saved: true);
      }
    } catch (_) {
      state = state.copyWith(
        loading: false,
        resultText: '번역 중 오류가 발생했어요. 다시 시도해주세요.',
      );
    }
  }
}

final popupControllerProvider =
    StateNotifierProvider<PopupController, PopupState>((ref) => PopupController(ref));
