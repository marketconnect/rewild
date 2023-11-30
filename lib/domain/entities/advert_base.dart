// ignore_for_file: public_member_api_docs, sort_constructors_first
class Advert {
  int campaignId;
  String name;
  DateTime endTime;
  DateTime createTime;
  DateTime changeTime;
  DateTime startTime;
  int dailyBudget;
  int status;
  int type;

  Advert({
    required this.campaignId,
    required this.name,
    required this.endTime,
    required this.createTime,
    required this.changeTime,
    required this.startTime,
    required this.dailyBudget,
    required this.status,
    required this.type,
  });

  Advert copyWith({
    int? campaignId,
    String? name,
    DateTime? endTime,
    DateTime? createTime,
    DateTime? changeTime,
    DateTime? startTime,
    int? dailyBudget,
    int? status,
    int? type,
  }) {
    return Advert(
      campaignId: campaignId ?? this.campaignId,
      name: name ?? this.name,
      endTime: endTime ?? this.endTime,
      createTime: createTime ?? this.createTime,
      changeTime: changeTime ?? this.changeTime,
      startTime: startTime ?? this.startTime,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}
