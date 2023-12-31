// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/advert_nm.dart';

class AdvertRecomendaionModel extends Advert {
  List<AdvertRecomendationParam>? params;

  AdvertRecomendaionModel({
    required super.campaignId,
    required super.name,
    required super.endTime,
    required super.createTime,
    required super.changeTime,
    required super.startTime,
    required super.dailyBudget,
    required super.status,
    required super.type,
    this.params,
  });

  factory AdvertRecomendaionModel.fromJson(Map<String, dynamic> json) {
    return AdvertRecomendaionModel(
      endTime: DateTime.parse(json['endTime']),
      createTime: DateTime.parse(json['createTime']),
      changeTime: DateTime.parse(json['changeTime']),
      startTime: DateTime.parse(json['startTime']),
      name: json['name'],
      params: json['params'] != null
          ? List<AdvertRecomendationParam>.from(json['params']
              .map((param) => AdvertRecomendationParam.fromJson(param)))
          : null,
      dailyBudget: json['dailyBudget'],
      campaignId: json['advertId'],
      status: json['status'],
      type: json['type'],
    );
  }

  @override
  String toString() =>
      'AdvertRecomendaionModel(campaignId: $campaignId, name: $name, endTime: $endTime, createTime: $createTime, changeTime: $changeTime, startTime: $startTime, dailyBudget: $dailyBudget, status: $status, type: $type)';
}

class AdvertRecomendationParam {
  String? subjectName;
  List<AdvertNm>? nms;
  int? subjectId;
  int? price;

  AdvertRecomendationParam({
    this.subjectName,
    this.nms,
    this.subjectId,
    this.price,
  });

  factory AdvertRecomendationParam.fromJson(Map<String, dynamic> json) {
    return AdvertRecomendationParam(
      subjectName: json['subjectName'],
      nms: json['nms'] != null
          ? List<AdvertNm>.from(json['nms'].map((nm) => AdvertNm.fromJson(nm)))
          : null,
      subjectId: json['subjectId'],
      price: json['price'],
    );
  }
}
