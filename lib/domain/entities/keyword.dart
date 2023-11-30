class Keyword {
  int campaignId;
  String keyword;
  int count;

  int diff = 0;
  void setDiff(int oldValue) {
    diff = count - oldValue;
  }

  bool _isNew = true;
  bool get isNew => _isNew;
  void setNotNew() {
    _isNew = false;
  }

  Keyword({
    required this.campaignId,
    required this.keyword,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': campaignId,
      'keyword': keyword,
      'count': count,
    };
  }

  factory Keyword.fromMap(Map<String, dynamic> map, int campaignId) {
    return Keyword(
      campaignId: campaignId,
      keyword: map['keyword'],
      count: map['count'],
    );
  }
}
