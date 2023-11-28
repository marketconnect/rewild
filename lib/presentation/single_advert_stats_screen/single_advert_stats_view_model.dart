import 'package:flutter/material.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/advert_card_model.dart';
import 'package:rewild/domain/entities/advert_catalogue_model.dart';
import 'package:rewild/domain/entities/advert_recomendation_model.dart';
import 'package:rewild/domain/entities/advert_search_model.dart';
import 'package:rewild/domain/entities/advert_search_plus_catalogue_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';

import 'package:rewild/presentation/notification_advert_screen/notification_advert_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

import '../../domain/entities/advert_base.dart';

abstract class SingleAdvertStatsViewModelAdvertStatsService {
  Future<Resource<AdvertStatModel>> getCurrent(int advertId);
  Future<Resource<List<AdvertStatModel>>> getTodays(int advertId);
}

abstract class SingleAdvertStatsViewModelAdvertService {
  Future<Resource<int>> getBudget(int advertId);

  Future<Resource<Advert>> advertInfo(int advertId);
  Future<Resource<bool>> stopAdvert(int advertId);
  Future<Resource<bool>> startAdvert(int advertId);

  Future<Resource<bool>> setCpm(
      {required int advertId,
      required int type,
      required int cpm,
      required int param,
      int? instrument});
}

// abstract class SingleAdvertStatsViewModelNotificationService {
//   // Future<Resource<void>> addNotification(ReWildNotificationModel notificate);
//   // Future<Resource<void>> delete(
//   //     int parentId, String property, String condition);
//   // Future<Resource<List<NotificationModel>>> getAll();
//   // Future<Resource<List<ReWildNotificationModel>>> getForParent(int parentId);
// }

class SingleAdvertStatsViewModel extends ResourceChangeNotifier {
  final SingleAdvertStatsViewModelAdvertStatsService advertStatService;
  final SingleAdvertStatsViewModelAdvertService advertService;
  // final SingleAdvertStatsViewModelNotificationService notificationService;
  final int advertId;

  SingleAdvertStatsViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.advertStatService,
    required this.advertService,
    // required this.notificationService,
    required this.advertId,
  }) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    // SqfliteService.printTableContent("advert_stat");

    SqfliteService.printTableContent("notifications");

    await _update();
  }

  Future<void> _update() async {
    final values = await Future.wait([
      fetch(() => advertService.advertInfo(advertId)), // advertInfo
      fetch(() => advertService.getBudget(advertId)), // budget
      fetch(() => advertStatService.getTodays(advertId)), // autoStatList
    ]);

    // Advert Info
    final advertInfo = values[0] as Advert?;
    final budget = values[1] as int?;
    final autoStatList = values[2] as List<AdvertStatModel>?;
    // final notificationList = values[3] as List<NotificationModel>?;

    if (advertInfo == null) {
      return;
    }
    setActive(advertInfo.status == 9);

    _setTitleCpm(advertInfo);

    setName(advertInfo.name);

    // Budget
    if (budget == null) {
      return;
    }
    setBudget(budget);

    // AutoStat List ==================================
    if (autoStatList == null || autoStatList.isEmpty) {
      return;
    }
    autoStatList.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    setAutoStatList(autoStatList);

    // set views
    final viewsDiff =
        autoStatList[autoStatList.length - 1].views - autoStatList[0].views;

    setTotalViews(autoStatList[autoStatList.length - 1].views);
    setViews(viewsDiff);

    // set clicks
    final clicksDiff =
        autoStatList[autoStatList.length - 1].clicks - autoStatList[0].clicks;
    setClicks(clicksDiff);
    setTotalClicks(autoStatList[autoStatList.length - 1].clicks);
    // set ctr
    final ctr = autoStatList[autoStatList.length - 1].ctr;
    setTotalCtr(ctr);

    // set ctr last
    final lastViewsDif =
        autoStatList[autoStatList.length - 1].views - autoStatList[0].views;
    if (lastViewsDif > 0) {
      final lastCtrDif = (autoStatList[autoStatList.length - 1].clicks -
              autoStatList[0].clicks) *
          100 /
          lastViewsDif;
      setLastCtr(lastCtrDif);
    }

    // set ctr diff
    final ctrDiff =
        autoStatList[autoStatList.length - 1].ctr - autoStatList[0].ctr;
    setCtrDiff(ctrDiff);

    // set cpc
    final cpc = autoStatList[autoStatList.length - 1].cpc;
    setCpc(cpc);

    // set cpc diff
    final cpcDiff =
        autoStatList[autoStatList.length - 1].cpc - autoStatList[0].cpc;
    setCpcDiff(cpcDiff);

    // set spent money
    setTotalSpentMoney(
        '${autoStatList[autoStatList.length - 1].spend.toStringAsFixed(0)}₽');

    setSpentMoney(
        '${(autoStatList[autoStatList.length - 1].spend - autoStatList[0].spend).toStringAsFixed(0)}₽');
  }

  // asyncInit finished ==========================================================================================
  void _setTitleCpm(Advert advertInfo) {
    switch (advertInfo.type) {
      case AdvertTypeConstants.auto:
        setTitle("Авто");
        if (advertInfo is AdvertAutoModel &&
            advertInfo.autoParams != null &&
            advertInfo.autoParams!.cpm != null) {
          setCpm(advertInfo.autoParams!.cpm!);
          if (advertInfo.autoParams!.subject != null) {
            subjectId = advertInfo.autoParams!.subject!.id!;
          }
        }
        _advType = AdvertTypeConstants.auto;
        break;
      case AdvertTypeConstants.inSearch:
        setTitle("В поиске");
        if (advertInfo is AdvertSearchModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          setCpm(advertInfo.params!.first.price!);
          if (advertInfo.params!.first.subjectId != null) {
            subjectId = advertInfo.params!.first.subjectId!;
          }
        }
        _advType = AdvertTypeConstants.inSearch;
        break;
      case AdvertTypeConstants.inCard:
        setTitle("В карточке");
        if (advertInfo is AdvertCardModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          setCpm(advertInfo.params!.first.price!);
        }
        _advType = AdvertTypeConstants.inCard;
        break;
      case AdvertTypeConstants.inCatalog:
        setTitle("В каталоге");
        if (advertInfo is AdvertCatalogueModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          setCpm(advertInfo.params!.first.price!);
          if (advertInfo.params!.first.menuId != null) {
            _menuId = advertInfo.params!.first.menuId!;
          }
        }
        _advType = AdvertTypeConstants.inCatalog;
        break;

      case AdvertTypeConstants.inRecomendation:
        setTitle("В рекомендациях");
        if (advertInfo is AdvertRecomendaionModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          setCpm(advertInfo.params!.first.price!);
          if (advertInfo.params!.first.subjectId != null) {
            subjectId = advertInfo.params!.first.subjectId!;
          }
        }
        _advType = AdvertTypeConstants.inRecomendation;

        break;
      case AdvertTypeConstants.searchPlusCatalog:
        setTitle("В поиске и каталоге");
        if (advertInfo is AdvertSearchPlusCatalogueModel &&
            advertInfo.unitedParams != null &&
            advertInfo.unitedParams!.first.catalogCPM != null) {
          setCpm(advertInfo.unitedParams!.first.catalogCPM!);
          if (advertInfo.unitedParams!.first.catalogCPM != null) {
            subjectId = advertInfo.unitedParams!.first.catalogCPM!;
          }
        }
        _advType = AdvertTypeConstants.searchPlusCatalog;
        break;
    }
  }

  // FIELDS =============================================================== FIELDS
  // for change cpm
  int subjectId = 0;
  int? _advType;
  // for In Catalogue
  int? _menuId;

  int? notificatedBudget;

  void setNotificatedBudget(int value) {
    notificatedBudget = value;
    notify();
  }

  int? get notificatedBudgetValue => notificatedBudget;

  // is active
  bool? _isActive;
  void setActive(bool value) {
    _isActive = value;
    notify();
  }

  bool get isActive => _isActive ?? false;

  String? _title;
  void setTitle(String value) {
    _title = value;
    notify();
  }

  String get title => _title ?? '';

  // name
  String? _name;
  void setName(String value) {
    _name = value;
    notify();
  }

  String get name => _name ?? '';

  // cpm
  int? _cpm;
  void setCpm(int value) {
    _cpm = value;
    notify();
  }

  int get cpm => _cpm ?? 0;

  // budget
  int? _budget;
  void setBudget(int value) {
    _budget = value;
    notify();
  }

  int get budget => _budget ?? 0;

  // views
  int? _totalViews;
  void setTotalViews(int value) {
    _totalViews = value;
    notify();
  }

  int get totalViews => _totalViews ?? 0;

  int? _views;
  void setViews(int value) {
    _views = value;
    notify();
  }

  int get views => _views ?? 0;

  // clicks
  double? _clicks;
  void setClicks(double value) {
    _clicks = value;
    notify();
  }

  int get clicks => _clicks == null ? 0 : _clicks!.toInt();

  double? _totalClicks;
  void setTotalClicks(double value) {
    _totalClicks = value;
    notify();
  }

  int get totalClicks => _totalClicks == null ? 0 : _totalClicks!.toInt();

  // ctr
  double? _lastCtr;
  void setLastCtr(double value) {
    _lastCtr = value;
    notify();
  }

  double get lastCtr => _lastCtr ?? 0;

  double? _totalCtr;
  void setTotalCtr(double value) {
    _totalCtr = value;
    notify();
  }

  double get totalCtr => _totalCtr ?? 0;

  // ctr diff
  String? _ctrDiff;
  void setCtrDiff(double value) {
    if (value == 0) {
      _ctrDiff = "";
    } else if (value > 0) {
      _ctrDiff = "+${value.toStringAsFixed(2)}";
    } else {
      _ctrDiff = "-${value.toStringAsFixed(2)}";
    }

    notify();
  }

  String get ctrDiff => _ctrDiff ?? "";

  // cpc
  double? _cpc;
  void setCpc(double value) {
    _cpc = value;
    notify();
  }

  double get cpc => _cpc ?? 0;

  // cpc diff
  double? _cpcDiff;
  void setCpcDiff(double value) {
    _cpcDiff = value;
    notify();
  }

  double get cpcDiff => _cpcDiff ?? 0;

  // spent money
  String? _totalSpentMoney;
  void setTotalSpentMoney(String value) {
    _totalSpentMoney = value;
    notify();
  }

  String get totalSpentMoney => _totalSpentMoney ?? "";

  String? _spentMoney;
  void setSpentMoney(String value) {
    _spentMoney = value;
    notify();
  }

  String get spentMoney => _spentMoney ?? "";

  List<AdvertStatModel> _autoStatList = [];
  void setAutoStatList(List<AdvertStatModel> value) {
    _autoStatList = value;
    notify();
  }

  List<AdvertStatModel> get autoStatList => _autoStatList;

  // PUBLIC METHODS ======================================================================== PUBLIC METHODS

  // Starts or stops advert
  Future<void> start() async {
    if (_isActive == null) {
      return;
    }
    if (!_isActive!) {
      await _start();
    }
  }

  // PRIVATE METHODS ======================================================================== PRIVATE METHODS
  Future<void> _start() async {
    final adv = await fetch(() => advertService.startAdvert(advertId));
    if (adv == null || !adv) {
      // could not start
      setActive(false); // still paused
      return;
    }
    // done
    setActive(true); // now active
    return;
  }

  void notificationsScreen() {
    final state = NotificationAdvertState(
      nmId: advertId,
      budget: budget,
    );

    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.advertNotificationScreen,
        arguments: state);
  }

  Future<void> changeCpm(String value) async {
    final cpm = int.tryParse(value) ?? 0;

    if (cpm != _cpm) {
      await _changeCpm(cpm);
      // print("changed");
    }
  }

  Future<void> _changeCpm(int cpm) async {
    if (_cpm == null || _advType == null) {
      return;
    }
    if (_advType != null &&
        _advType == AdvertTypeConstants.inCatalog &&
        _menuId != null) {
      await fetch(() => advertService.setCpm(
          advertId: advertId, cpm: cpm, type: _advType!, param: _menuId!));
    } else {
      await fetch(() => advertService.setCpm(
          advertId: advertId, cpm: cpm, type: _advType!, param: subjectId));
    }
    await _update();
  }
}
