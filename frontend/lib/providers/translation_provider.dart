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
final themesProvider = FutureProvider<List<Theme>>((ref) async{
    final apiService = ref.read(apiServiceProvider);
    return await apiService.getThemes();
});

final chatProvider = StateProvider<Map<String, List<ChatMessage>>>((ref) => {});

final vocabListProvider = StateProvider<Map<String, List<VocabEntry>>>((ref) => {});
