class VocabEntry{
    final String themeId;
    final String wordNative;
    final String wordTarget;
    final String? example;

    VocabEntry({
        required this.themeId,
        required this.wordNative,
        required this.wordTarget,
        this.example,
    });

    factory VocabEntry.fromJson(Map<String, dynamic> json){
        return VocabEntry(
            themeId: json['theme_id'],
            wordNative: json['word_native'],
            wordTarget: json['word_target'],
            example: json['example_sentence'],     
        );
    }
}
