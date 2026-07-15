import 'package:dio/dio.dart';
import '../constants.dart';
import '../models/translate_response.dart';
import '../models/classify_response.dart';
import '../models/llm_response.dart';

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

    Future<LLMResponse> translateLLM(String themeId, String text) async{
        final response = await _dio.post(
            '/translate/llm',
            data: {
                'theme_id': themeId,
                'text': text,
            },
        );
        return LLMResponse.fromJson(response.data);
    }
}

