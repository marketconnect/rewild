import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:rewild/domain/entities/keyword.dart';

class AutoStatWord {
  final List<Keyword> keywords;
  final List<String> excluded;
  AutoStatWord({
    required this.keywords,
    required this.excluded,
  });

  AutoStatWord copyWith({
    List<Keyword>? keywords,
    List<String>? excluded,
  }) {
    return AutoStatWord(
      keywords: keywords ?? this.keywords,
      excluded: excluded ?? this.excluded,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'keywords': keywords.map((x) => x.toMap()).toList(),
      'excluded': excluded.map((x) => x).toList(),
    };
  }

  factory AutoStatWord.fromMap(Map<String, dynamic> map, int campaignId) {
    List<Keyword> keywords = List<Keyword>.from(
      map['keywords']?.map((x) => Keyword.fromMap(x, campaignId)),
    );

    List<String> excluded =
        map['excluded'].map<String>((e) => e.toString()).toList();

    return AutoStatWord(
      keywords: keywords,
      excluded: excluded,
    );
  }

  String toJson() => json.encode(toMap());

  factory AutoStatWord.fromJson(String source, int campaignId) =>
      AutoStatWord.fromMap(
          json.decode(source) as Map<String, dynamic>, campaignId);

  @override
  String toString() => 'AutoStatWord(keywords: $keywords, excluded: $excluded)';

  @override
  bool operator ==(covariant AutoStatWord other) {
    if (identical(this, other)) return true;

    return listEquals(other.keywords, keywords) &&
        listEquals(other.excluded, excluded);
  }

  @override
  int get hashCode => keywords.hashCode ^ excluded.hashCode;
}
