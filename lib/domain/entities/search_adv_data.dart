class SearchAdvData {
  final int id;
  final int cpm;
  final int subject;
  final int order;
  final int pos; // Define the type based on your data structure

  SearchAdvData(
      {required this.id,
      required this.cpm,
      required this.subject,
      required this.pos,
      required this.order});

  factory SearchAdvData.fromJson(Map<String, dynamic> json) {
    return SearchAdvData(
      id: json['id'],
      cpm: json['cpm'],
      subject: json['subject'],
      pos: json['pos'],
      order: json['order'],
    );
  }
}
