class TranslateResponse{
    final String wordNative;
    final String wordTarget;

    TranslateResponse({
        required this.wordNative,
        required this.wordTarget,
    });
    
    factory TranslateResponse.fromJson(Map<String, dynamic> json){
        return TranslateResponse(
            wordNative: json['word_native'],
            wordTarget: json['word_target'],
        );
    }
}
