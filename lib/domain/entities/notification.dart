// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ReWildNotificationModel {
  int parentId;
  int condition;
  String value;
  int? sizeId;
  int? wh;
  bool reusable;
  ReWildNotificationModel({
    required this.parentId,
    required this.condition,
    required this.value,
    this.reusable = false,
    this.sizeId,
    this.wh,
  });

  // bool isConditionMet(int condition, double value) {
  //   if (condition == NotificationConditionConstants.lessThanCondition) {
  //     return value < this.doubleValue;
  //   } else if (condition ==
  //       NotificationConditionConstants.greaterThanCondition) {
  //     return value > this.doubleValue;
  //   } else if (condition == NotificationConditionConstants.changedCondition) {
  //     return this.doubleValue != value;
  //   }
  //   return false;
  // }

  ReWildNotificationModel copyWith({
    int? parentId,
    int? condition,
    String? value,
    int? sizeId,
    int? wh,
  }) {
    return ReWildNotificationModel(
      parentId: parentId ?? this.parentId,
      condition: condition ?? this.condition,
      value: value ?? this.value,
      sizeId: sizeId ?? this.sizeId,
      wh: wh ?? this.wh,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'parentId': parentId,
      'condition': condition,
      'value': value,
      'sizeId': sizeId,
      'wh': wh,
    };
  }

  factory ReWildNotificationModel.fromMap(Map<String, dynamic> map) {
    print(map);
    return ReWildNotificationModel(
      parentId: map['parentId'] as int,
      condition: map['condition'] as int,
      value: map['value'] as String,
      sizeId: map['sizeId'] != null ? map['sizeId'] as int : null,
      wh: map['wh'] != null ? map['wh'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReWildNotificationModel.fromJson(String source) =>
      ReWildNotificationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationModel(parentId: $parentId, condition: $condition, value: $value, sizeId: $sizeId, wh: $wh)';
  }

  @override
  bool operator ==(covariant ReWildNotificationModel other) {
    if (identical(this, other)) return true;

    return other.parentId == parentId &&
        other.condition == condition &&
        other.value == value &&
        other.sizeId == sizeId &&
        other.wh == wh;
  }

  @override
  int get hashCode {
    return parentId.hashCode ^
        condition.hashCode ^
        value.hashCode ^
        sizeId.hashCode ^
        wh.hashCode;
  }
}
