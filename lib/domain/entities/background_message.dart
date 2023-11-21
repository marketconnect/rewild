// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BackgroundMessage {
  final int subject;
  final int id;
  final int condition;
  final String header;
  final String message;
  final DateTime dateTime;

  BackgroundMessage({
    required this.subject,
    required this.id,
    required this.condition,
    required this.header,
    required this.message,
    required this.dateTime,
  });

  static const int card = 1;
  static const int advert = 2;

  BackgroundMessage copyWith({
    int? subject,
    int? id,
    int? condition,
    String? header,
    String? message,
    DateTime? dateTime,
  }) {
    return BackgroundMessage(
      subject: subject ?? this.subject,
      id: id ?? this.id,
      condition: condition ?? this.condition,
      header: header ?? this.header,
      message: message ?? this.message,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subject': subject,
      'id': id,
      'condition': condition,
      'header': header,
      'message': message,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory BackgroundMessage.fromMap(Map<String, dynamic> map) {
    return BackgroundMessage(
      subject: map['subject'] as int,
      id: map['id'] as int,
      condition: map['condition'] as int,
      header: map['header'] as String,
      message: map['message'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory BackgroundMessage.fromJson(String source) =>
      BackgroundMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BackgroundMessage(subject: $subject, id: $id, condition: $condition, header: $header, message: $message, dateTime: $dateTime)';
  }

  @override
  bool operator ==(covariant BackgroundMessage other) {
    if (identical(this, other)) return true;

    return other.subject == subject &&
        other.id == id &&
        other.condition == condition &&
        other.header == header &&
        other.message == message &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode {
    return subject.hashCode ^
        id.hashCode ^
        condition.hashCode ^
        header.hashCode ^
        message.hashCode ^
        dateTime.hashCode;
  }
}
