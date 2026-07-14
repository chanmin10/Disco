class LLMResponse{
    final String text;

    LLMResponse({
        required this.text,
    });

    factory LLMResponse.fromJson(Map<String, dynamic> json){
        return LLMResponse(
            text: json['text'],
        );
    }
}
