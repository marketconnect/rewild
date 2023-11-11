// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AutoStatModel {
  int advertId;
  int views;
  double clicks;
  double ctr;
  double cpc;
  int spend;
  DateTime createdAt;

  AutoStatModel({
    required this.views,
    required this.clicks,
    required this.ctr,
    required this.cpc,
    required this.spend,
    required this.advertId,
    required this.createdAt,
  });

  AutoStatModel copyWith({
    int? views,
    double? clicks,
    double? ctr,
    double? cpc,
    int? spend,
    int? advertId,
  }) {
    return AutoStatModel(
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      ctr: ctr ?? this.ctr,
      cpc: cpc ?? this.cpc,
      spend: spend ?? this.spend,
      advertId: advertId ?? this.advertId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'views': views,
      'clicks': clicks,
      'ctr': ctr,
      'cpc': cpc,
      'spend': spend,
      'advertId': advertId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AutoStatModel.fromMap(Map<String, dynamic> map, int advertId) {
    final clicks = map['clicks'] is double
        ? map['clicks']
        : (map['clicks'] as int).toDouble();
    final ctr =
        map['ctr'] is double ? map['ctr'] : (map['ctr'] as int).toDouble();
    final cpc =
        map['cpc'] is double ? map['cpc'] : (map['cpc'] as int).toDouble();

    final createdAt = map['createdAt'] is String
        ? DateTime.parse(map['createdAt'])
        : DateTime.now();

    return AutoStatModel(
      views: map['views'] as int,
      clicks: clicks,
      ctr: ctr,
      cpc: cpc,
      spend: map['spend'] as int,
      advertId: advertId,
      createdAt: createdAt,
    );
  }

  String toJson() => json.encode(toMap());

  factory AutoStatModel.fromJson(Map<String, dynamic> source, int advertId) =>
      AutoStatModel.fromMap(source, advertId);

  @override
  String toString() {
    return 'AutoStat(views: $views, clicks: $clicks, ctr: $ctr, cpc: $cpc, spend: $spend)';
  }

  @override
  bool operator ==(covariant AutoStatModel other) {
    if (identical(this, other)) return true;

    return other.views == views &&
        other.clicks == clicks &&
        other.ctr == ctr &&
        other.cpc == cpc &&
        other.spend == spend;
  }

  @override
  int get hashCode {
    return views.hashCode ^
        clicks.hashCode ^
        ctr.hashCode ^
        cpc.hashCode ^
        spend.hashCode;
  }
}
