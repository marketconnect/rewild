// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotificationModel {
  int parentId;
  String property;
  double? minValue;
  double? maxValue;
  bool? changed;
  NotificationModel({
    required this.parentId,
    required this.property,
    this.minValue,
    this.maxValue,
    this.changed,
  });

  NotificationModel copyWith({
    int? parentId,
    String? property,
    double? minValue,
    double? maxValue,
    bool? changed,
  }) {
    return NotificationModel(
      parentId: parentId ?? this.parentId,
      property: property ?? this.property,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      changed: changed ?? this.changed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'parentId': parentId,
      'property': property,
      'minValue': minValue,
      'maxValue': maxValue,
      'trigger': changed,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      parentId: map['parentId'] as int,
      property: map['property'] as String,
      minValue: map['minValue'] != null ? map['minValue'] as double : null,
      maxValue: map['maxValue'] != null ? map['maxValue'] as double : null,
      changed: map['trigger'] != null ? map['trigger'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificateModel(parentId: $parentId, property: $property, minValue: $minValue, maxValue: $maxValue, trigger: $changed)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.parentId == parentId &&
        other.property == property &&
        other.minValue == minValue &&
        other.maxValue == maxValue &&
        other.changed == changed;
  }

  @override
  int get hashCode {
    return parentId.hashCode ^
        property.hashCode ^
        minValue.hashCode ^
        maxValue.hashCode ^
        changed.hashCode;
  }
}
