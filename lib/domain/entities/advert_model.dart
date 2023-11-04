class Advert {
  int advertId;
  int type;
  int status;
  String dailyBudget;
  DateTime createTime;
  DateTime changeTime;
  DateTime startTime;
  DateTime endTime;

  Advert({
    required this.advertId,
    required this.type,
    required this.status,
    required this.dailyBudget,
    required this.createTime,
    required this.changeTime,
    required this.startTime,
    required this.endTime,
  });

  factory Advert.fromJson(Map<String, dynamic> json) {
    return Advert(
      advertId: json['advertId'],
      type: json['type'],
      status: json['status'],
      dailyBudget: json['dailyBudget'],
      createTime: DateTime.parse(json['createTime']),
      changeTime: DateTime.parse(json['changeTime']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }
}
