class Keyword {
  int? id;
  String keyword;
  int count;

  Keyword({
    this.id,
    required this.keyword,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'keyword': keyword,
      'count': count,
    };
  }

  factory Keyword.fromMap(Map<String, dynamic> map) {
    print('keyword: $map');
    return Keyword(
      id: map['id'],
      keyword: map['keyword'],
      count: map['count'],
    );
  }
}
