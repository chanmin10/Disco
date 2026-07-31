import 'package:dio/dio.dart';
import '../constants.dart';
import '../models/translate_response.dart';
import '../models/classify_response.dart';
import '../models/llm_response.dart';
import '../models/theme.dart';
import '../models/vocab_entry.dart';

class ApiService{
    final Dio _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
    ));

    Future<TranslateResponse> translateQuick(String themeId, String text) async{
        final response = await _dio.post(
            '/translate/quick',
            data: {
                'theme_id': themeId,
                'text': text,
            },
        );
        return TranslateResponse.fromJson(response.data);
    }

    Future<ClassifyResponse> classify(String themeId, String textNative, String textTarget) async{
        final response = await _dio.post(
            '/translate/classify',
            data: {
                'theme_id': themeId,
                'text_native': textNative,
                'text_target': textTarget,
            },
        );
        return ClassifyResponse.fromJson(response.data);
    }

    Future<LLMResponse> translateAi(String themeId, String text) async{
        final response = await _dio.post(
            '/translate/ai',
            data: {
                'theme_id': themeId,
                'text': text,
            },
        );
        return LLMResponse.fromJson(response.data);
    }

    Future<List<Theme>> getThemes() async{
        final response = await _dio.get('/themes');

        return (response.data as List)
            .map((item) => Theme.fromJson(item))
            .toList();
    }

    Future<Theme> createTheme(String name, String targetLanguage) async{
        final response = await _dio.post(
            '/themes',
            data: {
                'name': name,
                'target_language': targetLanguage,
            }
        );

        return Theme.fromJson(response.data);
    }

    Future<List<VocabEntry>> getVocab(String themeId) async{
        final response = await _dio.get(
            '/vocab',
            queryParameters: {
                'theme_id': themeId,
            },
        );

        return (response.data as List)
            .map((item) => VocabEntry.fromJson(item))
            .toList();
    }
}
