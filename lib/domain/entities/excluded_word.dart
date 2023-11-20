class ExcludedWord {
  int? id;
  String word;

  ExcludedWord({
    this.id,
    required this.word,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
    };
  }

  factory ExcludedWord.fromMap(Map<String, dynamic> map) {
    print('excluded word: $map');
    return ExcludedWord(
      id: map['id'],
      word: map['word'],
    );
  }
}
