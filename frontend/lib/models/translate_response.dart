class TranslateResponse{
    final String response;
    final String textNative;
    final String textTarget;

    TranslateResponse({
        required this.response,
        required this.textNative,
        required this.textTarget,
    });

    factory TranslateResponse.fromJson(Map<String, dynamic> json){
        return TranslateResponse(
            response: json['response'],
            textNative: json['text_native'],
            textTarget: json['text_target'],
        );
    }
}
