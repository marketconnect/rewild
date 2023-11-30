import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/advert_nm.dart';

class AdvertSearchModel extends Advert {
  bool? searchPluseState;
  List<AdvertSearchParam>? params;

  AdvertSearchModel({
    required super.campaignId,
    required super.name,
    required super.endTime,
    required super.createTime,
    required super.changeTime,
    required super.startTime,
    required super.dailyBudget,
    required super.status,
    required super.type,
    this.searchPluseState,
    this.params,
  });

  factory AdvertSearchModel.fromJson(Map<String, dynamic> json) {
    return AdvertSearchModel(
      endTime: DateTime.parse(json['endTime']),
      createTime: DateTime.parse(json['createTime']),
      changeTime: DateTime.parse(json['changeTime']),
      startTime: DateTime.parse(json['startTime']),
      searchPluseState: json['searchPluseState'],
      name: json['name'],
      params: json['params'] != null
          ? List<AdvertSearchParam>.from(
              json['params'].map((param) => AdvertSearchParam.fromJson(param)))
          : null,
      dailyBudget: json['dailyBudget'],
      campaignId: json['advertId'],
      status: json['status'],
      type: json['type'],
    );
  }
}

class AdvertSearchParam {
  bool? active;
  String? subjectName;
  List<AdvertSearchInterval>? intervals;
  List<AdvertNm>? nms;
  int? subjectId;
  int? price;

  AdvertSearchParam({
    required this.active,
    required this.subjectName,
    required this.intervals,
    required this.nms,
    required this.subjectId,
    required this.price,
  });

  factory AdvertSearchParam.fromJson(Map<String, dynamic> json) {
    return AdvertSearchParam(
      active: json['active'],
      subjectName: json['subjectName'],
      intervals: json['intervals'] != null
          ? List<AdvertSearchInterval>.from(json['intervals']
              .map((interval) => AdvertSearchInterval.fromJson(interval)))
          : null,
      nms: json['nms'] != null
          ? List<AdvertNm>.from(json['nms'].map((nm) => AdvertNm.fromJson(nm)))
          : null,
      subjectId: json['subjectId'],
      price: json['price'],
    );
  }
}

class AdvertSearchInterval {
  int? begin;
  int? end;

  AdvertSearchInterval({
    required this.begin,
    required this.end,
  });

  factory AdvertSearchInterval.fromJson(Map<String, dynamic> json) {
    return AdvertSearchInterval(
      begin: json['begin'],
      end: json['end'],
    );
  }
}
