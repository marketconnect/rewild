// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PursuedModel {
  int parentId;
  String property;
  PursuedModel({
    required this.parentId,
    required this.property,
  });

  PursuedModel copyWith({
    int? parentId,
    String? property,
  }) {
    return PursuedModel(
      parentId: parentId ?? this.parentId,
      property: property ?? this.property,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'parentId': parentId,
      'property': property,
    };
  }

  factory PursuedModel.fromMap(Map<String, dynamic> map) {
    return PursuedModel(
      parentId: map['parentId'] as int,
      property: map['property'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PursuedModel.fromJson(String source) =>
      PursuedModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Pursued(parentId: $parentId, property: $property)';

  @override
  bool operator ==(covariant PursuedModel other) {
    if (identical(this, other)) return true;

    return other.parentId == parentId && other.property == property;
  }

  @override
  int get hashCode => parentId.hashCode ^ property.hashCode;
}
