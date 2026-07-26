class Theme{
    final String id;
    final String name;
    final String targetLanguage;

    Theme({
        required this.id,
        required this.name,
        required this.targetLanguage,
    });
    
    factory Theme.fromJson(Map<String, dynamic> json){
        return Theme(
            id: json['id'],
            name: json['name'],
            targetLanguage: json['target_language'],
        );
    }
}
