// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AdvertStatModel {
  int campaignId;
  int views;
  double clicks;
  double ctr;
  double cpc;
  int spend;
  DateTime createdAt;

  AdvertStatModel({
    required this.views,
    required this.clicks,
    required this.ctr,
    required this.cpc,
    required this.spend,
    required this.campaignId,
    required this.createdAt,
  });

  AdvertStatModel copyWith({
    int? views,
    double? clicks,
    double? ctr,
    double? cpc,
    int? spend,
    int? campaignId,
  }) {
    return AdvertStatModel(
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      ctr: ctr ?? this.ctr,
      cpc: cpc ?? this.cpc,
      spend: spend ?? this.spend,
      campaignId: campaignId ?? this.campaignId,
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
      'campaignId': campaignId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AdvertStatModel.fromMap(Map<String, dynamic> map, int campaignId) {
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

    // for auto 'spend' for search 'sum'
    int? spend = map['spend'];

    if (spend == null) {
      final sum = map['sum'] as double;
      spend = sum > 0 ? sum.toInt() : 0;
    }

    return AdvertStatModel(
      views: map['views'] as int,
      clicks: clicks,
      ctr: ctr,
      cpc: cpc,
      spend: spend,
      campaignId: campaignId,
      createdAt: createdAt,
    );
  }

  String toJson() => json.encode(toMap());

  factory AdvertStatModel.fromJson(
          Map<String, dynamic> source, int campaignId) =>
      AdvertStatModel.fromMap(source, campaignId);

  @override
  String toString() {
    return 'AdvertStatModel(campaignId: $campaignId, views: $views, clicks: $clicks, ctr: $ctr, cpc: $cpc, spend: $spend, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant AdvertStatModel other) {
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
