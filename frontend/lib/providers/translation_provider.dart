import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translate_response.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../models/theme.dart';
import '../models/vocab_entry.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final inputProvider = StateProvider<String>((ref) => "");
final isLoadingProvider = StateProvider<bool>((ref) => false);
final translationProvider = StateProvider<TranslateResponse?>((ref) => null);
final selectedThemeProvider = StateProvider<String?>((ref) => null);
final isLeftSidebarOpen = StateProvider<bool>((ref) => true);
final isRightSidebarOpen = StateProvider<bool>((ref) => true);
final engineProvider = StateProvider<String>((ref) => 'general');
final newThemePickerOpenProvider = StateProvider<bool>((ref) => false);

final themesProvider = FutureProvider<List<Theme>>((ref) async{
    final apiService = ref.read(apiServiceProvider);
    return await apiService.getThemes();
});

/// The currently selected theme, resolved from [themesProvider] + [selectedThemeProvider].
final activeThemeProvider = Provider<Theme?>((ref) {
    final themes = ref.watch(themesProvider).valueOrNull ?? const [];
    final selectedId = ref.watch(selectedThemeProvider);
    if (themes.isEmpty) return null;
    return themes.firstWhere(
        (t) => t.id == selectedId,
        orElse: () => themes.first,
    );
});

class ChatNotifier extends StateNotifier<Map<String, List<ChatMessage>>> {
    ChatNotifier() : super({});

    void addMessage(String themeId, ChatMessage message) {
        final current = state[themeId] ?? const [];
        state = {...state, themeId: [...current, message]};
    }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, Map<String, List<ChatMessage>>>((ref) => ChatNotifier());

/// Vocab is never mutated locally — it always mirrors the DB via GET /vocab.
class VocabListNotifier extends StateNotifier<Map<String, List<VocabEntry>>> {
    VocabListNotifier(this._ref) : super({});
    final Ref _ref;

    Future<void> refresh(String themeId) async {
        final api = _ref.read(apiServiceProvider);
        final entries = await api.getVocab(themeId);
        state = {...state, themeId: entries};
    }
}

final vocabListProvider =
    StateNotifierProvider<VocabListNotifier, Map<String, List<VocabEntry>>>(
        (ref) => VocabListNotifier(ref));
