class VocabItem {
  final String id;
  final String word;
  final String sub;
  final bool isNew;

  const VocabItem({
    required this.id,
    required this.word,
    required this.sub,
    this.isNew = false,
  });

  VocabItem copyWith({String? word, String? sub, bool? isNew}) {
    return VocabItem(
      id: id,
      word: word ?? this.word,
      sub: sub ?? this.sub,
      isNew: isNew ?? this.isNew,
    );
  }
}
