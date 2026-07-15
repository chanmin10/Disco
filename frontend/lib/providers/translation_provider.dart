import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translate_response.dart';

final inputProvider = StateProvider<String>((ref) => "");
final isLoadingProvider = StateProvider<bool>((ref) => false);
final translationProvider = StateProvider<TranslateResponse?> ((ref)=> null);
final vocabListProvider = StateProvider<List>((ref) => []);
final chatProvider = StateProvider<List>((ref) => []);
final selectedThemeProvider = StateProvider<String?>((ref) => null);
