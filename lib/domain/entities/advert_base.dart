// ignore_for_file: public_member_api_docs, sort_constructors_first
class Advert {
  int advertId;
  String name;
  DateTime endTime;
  DateTime createTime;
  DateTime changeTime;
  DateTime startTime;
  int dailyBudget;
  int status;
  int type;

  Advert({
    required this.advertId,
    required this.name,
    required this.endTime,
    required this.createTime,
    required this.changeTime,
    required this.startTime,
    required this.dailyBudget,
    required this.status,
    required this.type,
  });
}
