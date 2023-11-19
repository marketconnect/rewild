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
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/presentation/single_advert_stats_screen/widgets/modal_bottom_widget.dart';

import '../../domain/entities/advert_base.dart';

abstract class SingleAdvertStatsViewModelAdvertStatsService {
  Future<Resource<AdvertStatModel>> getCurrent(int advertId);
  Future<Resource<List<AdvertStatModel>>> getAll(int advertId);
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

abstract class SingleAdvertStatsViewModelNotificationService {
  Future<Resource<void>> addNotification(NotificationModel notificate);
  Future<Resource<void>> delete(
      int parentId, String property, String condition);
  Future<Resource<List<NotificationModel>>> getAll();
  Future<Resource<List<NotificationModel>>> getForParent(int parentId);
}

class SingleAdvertStatsViewModel extends ResourceChangeNotifier {
  final SingleAdvertStatsViewModelAdvertStatsService advertStatService;
  final SingleAdvertStatsViewModelAdvertService advertService;
  final SingleAdvertStatsViewModelNotificationService notificationService;
  final int advertId;

  SingleAdvertStatsViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.advertStatService,
    required this.advertService,
    required this.notificationService,
    required this.advertId,
  }) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    SqfliteService.printTableContent("advert_stat");

    SqfliteService.printTableContent("notifications");

    final values = await Future.wait([
      fetch(() => advertService.advertInfo(advertId)), // advertInfo
      fetch(() => advertService.getBudget(advertId)), // budget
      fetch(() => advertStatService.getAll(advertId)), // autoStatList
      fetch(() => notificationService.getForParent(advertId)), // notification
    ]);

    // Advert Info
    final advertInfo = values[0] as Advert?;
    final budget = values[1] as int?;
    final autoStatList = values[2] as List<AdvertStatModel>?;
    final notificationList = values[3] as List<NotificationModel>?;
    if (advertInfo == null) {
      return;
    }
    setActive(advertInfo.status == 9);

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
        break;
      case AdvertTypeConstants.inCard:
        setTitle("В карточке");
        if (advertInfo is AdvertCardModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          setCpm(advertInfo.params!.first.price!);
        }

        break;
      case AdvertTypeConstants.inCatalog:
        setTitle("В каталоге");
        if (advertInfo is AdvertCatalogueModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          setCpm(advertInfo.params!.first.price!);
        }

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
    }

    setName(advertInfo.name);

    // Budget
    if (budget == null) {
      return;
    }
    setBudget(budget);

    // notification
    if (notificationList == null) {
      return;
    }

    // for (final notification in notificationList) {
    //   final property = notification.property;
    //   // if (property == NotificationPropertyConstants.budget) {
    //   //   // _modalBottomState = _modalBottomState.copyWith(
    //   //   //     trackMinBudget: true, minBudget: int.tryParse(notification.value));
    //   // }
    // }

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
  } // asyncInit finished ==========================================================================================

  // FIELDS =============================================================== FIELDS
  // for change cpm
  int subjectId = 0;

  // modal bottom state
  // is pursued
  // ModalBottomWidgetState _modalBottomState = ModalBottomWidgetState(
  //     isPursued: false,
  //     isActive: false,
  //     cpm: 0,
  //     trackMinBudget: false,
  //     minBudget: 0,
  //     minCtr: 0,
  //     trackMinCtr: false);

  // ModalBottomWidgetState get modalBottomState => _modalBottomState;

  // is active
  bool? _isActive;
  void setActive(bool value) {
    // _modalBottomState = _modalBottomState.copyWith(
    //   isActive: value,
    // );
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
  // saves changes from modal bottom widget to local storage and Wb API
  // updates screen
  Future<void> save(ModalBottomWidgetState state) async {
    final isActive = state.isActive;
    if (isActive != _isActive) {
      await start();
    }

    final cpm = state.cpm;
    if (cpm != _cpm) {
      await _changeCpm(cpm);
    }

    // final minBudget = state.minBudget;
    // if (minBudget != _modalBottomState.minBudget) {
    //   await _changeMinBudgetNotification(minBudget);
    // }

    _asyncInit();
  }

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

  // Future<void> _stop() async {
  //   final adv = await fetch(() => advertService.stopAdvert(advertId));
  //   if (adv == null || !adv) {
  //     // could not stop
  //     setActive(true); // still active
  //     return;
  //   }
  //   // done
  //   setActive(false); // now paused
  //   return;
  // }

  // // Pursue callback
  // Future<void> _changePursue() async {
  //   if (_isPursued == null) {
  //     return;
  //   }
  //   if (_isPursued!) {
  //     await _untrack();
  //   } else {
  //     await _track();
  //   }

  //   final isPursued = await fetch(() => advertService.isPursued(advertId));
  //   if (isPursued == null) {
  //     return;
  //   }
  //   setPursued(isPursued);
  // }

  // Future<void> _track() async {
  //   final ok = await fetch(() => advertService.addToTrack(advertId));
  //   if (ok == null) {
  //     return;
  //   }
  //   setPursued(ok);
  // }

  // Future<void> _untrack() async {
  //   final ok = await fetch(() => advertService.deleteFromTrack(advertId));
  //   if (ok == null) {
  //     return;
  //   }
  //   setPursued(ok);
  // }

  Future<void> _changeCpm(int cpm) async {
    if (_cpm == null) {
      return;
    }
    await fetch(() => advertService.setCpm(
        advertId: advertId, cpm: cpm, type: 8, param: subjectId));
  }

  // Future<void> _changeMinBudgetNotification(int minBdget) async {
  //   await fetch(() => notificationService.addNotification(NotificationModel(
  //       parentId: advertId,
  //       property: NotificationPropertyConstants.budget,
  //       condition: NotificationConditionConstants.lessThanCondition,
  //       value: minBdget.toString())));
  // }

  // Future<void> _changeMinCtrNotification(int minCtr) async {
  //   await fetch(() => notificationService.addNotification(NotificationModel(
  //       parentId: advertId,
  //       property: NotificationPropertyConstants.ctr,
  //       condition: NotificationPropertyConstants.lessThanCondition,
  //       doubleValue: minCtr.toDouble())));
  // }

  // Future<void> _saveNotification(String property, double minValue) {
  //   final newNotification = NotificationModel(
  //     parentId: advertId,
  //     property: property,
  //     minValue: minValue,
  //   );
  //   return fetch(() => notificationService.addNotification(newNotification));
  // }

  // Future<void> _deleteNotification(String property) {
  //   return fetch(() => notificationService.delete(advertId, property));
  // }
}
