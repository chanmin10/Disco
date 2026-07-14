class ClassifyResponse{
    final bool isVocab;
    
    ClassifyResponse({
        required this.isVocab,
    });
    
    factory ClassifyResponse.fromJson(Map<String, dynamic> json){
        return ClassifyResponse(
            isVocab: json['is_vocab'],
        );
    }
} 
