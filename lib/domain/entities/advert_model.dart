import 'dart:convert';

class AdvertInfoModel {
  int advertId;
  int type;
  int status;
  int dailyBudget;
  DateTime createTime;
  DateTime changeTime;
  String name;
  DateTime startTime;
  DateTime endTime;

  AdvertInfoModel({
    required this.advertId,
    required this.type,
    required this.status,
    required this.dailyBudget,
    required this.createTime,
    required this.changeTime,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  factory AdvertInfoModel.fromJson(Map<String, dynamic> json) {
    return AdvertInfoModel(
      advertId: json['advertId'],
      type: json['type'],
      name: json['name'],
      status: json['status'],
      dailyBudget: json['dailyBudget'],
      createTime: DateTime.parse(json['createTime']),
      changeTime: DateTime.parse(json['changeTime']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

  AdvertInfoModel copyWith({
    int? advertId,
    int? type,
    int? status,
    int? dailyBudget,
    DateTime? createTime,
    DateTime? changeTime,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return AdvertInfoModel(
      advertId: advertId ?? this.advertId,
      type: type ?? this.type,
      status: status ?? this.status,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      createTime: createTime ?? this.createTime,
      changeTime: changeTime ?? this.changeTime,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'advertId': advertId,
      'type': type,
      'status': status,
      'dailyBudget': dailyBudget,
      'createTime': createTime.millisecondsSinceEpoch,
      'changeTime': changeTime.millisecondsSinceEpoch,
      'name': name,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
    };
  }

  factory AdvertInfoModel.fromMap(Map<String, dynamic> map) {
    return AdvertInfoModel(
      advertId: map['advertId'] as int,
      type: map['type'] as int,
      status: map['status'] as int,
      dailyBudget: map['dailyBudget'] as int,
      createTime: DateTime.fromMillisecondsSinceEpoch(map['createTime'] as int),
      changeTime: DateTime.fromMillisecondsSinceEpoch(map['changeTime'] as int),
      name: map['name'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'AdvertModel(advertId: $advertId, type: $type, status: $status, dailyBudget: $dailyBudget, createTime: $createTime, changeTime: $changeTime, name: $name, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(covariant AdvertInfoModel other) {
    if (identical(this, other)) return true;

    return other.advertId == advertId &&
        other.type == type &&
        other.status == status &&
        other.dailyBudget == dailyBudget &&
        other.createTime == createTime &&
        other.changeTime == changeTime &&
        other.name == name &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode {
    return advertId.hashCode ^
        type.hashCode ^
        status.hashCode ^
        dailyBudget.hashCode ^
        createTime.hashCode ^
        changeTime.hashCode ^
        name.hashCode ^
        startTime.hashCode ^
        endTime.hashCode;
  }
}
