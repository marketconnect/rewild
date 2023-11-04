import 'dart:convert';

class ApiKeyModel {
  final String token;
  final String type;
  bool isSelected = false;
  void toggleSelected() {
    isSelected = !isSelected;
  }

  ApiKeyModel({
    required this.token,
    required this.type,
  });

  ApiKeyModel copyWith({
    String? token,
    String? type,
  }) {
    return ApiKeyModel(
      token: token ?? this.token,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'token': token, 'type': type};
  }

  factory ApiKeyModel.fromMap(Map<String, dynamic> map) {
    return ApiKeyModel(
      token: map['token'] as String,
      type: map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiKeyModel.fromJson(String source) =>
      ApiKeyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ApiKeyModel( token: $token, type: $type)';

  @override
  bool operator ==(covariant ApiKeyModel other) {
    if (identical(this, other)) return true;

    return other.token == token && other.type == type;
  }

  @override
  int get hashCode => token.hashCode ^ type.hashCode;
}
