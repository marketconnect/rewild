class SpellResult {
  final int code;
  final int pos;
  final int row;
  final int col;
  final int len;
  final String word;
  final List<String> suggestions;

  SpellResult({
    required this.code,
    required this.pos,
    required this.row,
    required this.col,
    required this.len,
    required this.word,
    required this.suggestions,
  });

  factory SpellResult.fromJson(Map<String, dynamic> json) {
    return SpellResult(
      code: json['code'],
      pos: json['pos'],
      row: json['row'],
      col: json['col'],
      len: json['len'],
      word: json['word'],
      suggestions: List<String>.from(json['s'].map((x) => x)),
    );
  }
}
