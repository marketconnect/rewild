import 'package:flutter/foundation.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/auto_stat.dart';
import 'package:rewild/domain/entities/notificate.dart';
import 'package:rewild/presentation/auto_advert_screen/widgets/modal_bottom_widget.dart';

import '../../domain/entities/advert_base.dart';

abstract class AutoAdvertViewModelAutoAdvertService {
  Future<Resource<AutoStatModel>> getCurrent(int advertId);
  Future<Resource<List<AutoStatModel>>> getAll(int advertId);
}

abstract class AutoAdvertViewModelAdvertService {
  Future<Resource<int>> getBudget(int advertId);
  Future<Resource<bool>> isPursued(int advertId);
  Future<Resource<bool>> addToTrack(int advertId);
  Future<Resource<bool>> deleteFromTrack(int advertId);
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

abstract class AutoAdvertViewModelNotificationService {
  Future<Resource<void>> addNotification(NotificationModel notificate);
  Future<Resource<void>> delete(int parentId, String property);
  Future<Resource<List<NotificationModel>>> getForParent(int parentId);
}

class AutoAdvertViewModel extends ResourceChangeNotifier {
  final AutoAdvertViewModelAutoAdvertService autoStatService;
  final AutoAdvertViewModelAdvertService advertService;
  final AutoAdvertViewModelNotificationService notificationService;
  final int advertId;

  AutoAdvertViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.autoStatService,
    required this.advertService,
    required this.notificationService,
    required this.advertId,
  }) {
    _asyncInit();
  }

  // FIELDS =============================================================== FIELDS
  // for change cpm
  int subjectId = 0;

  // modal bottom state
  // is pursued
  ModalBottomWidgetState _modalBottomState = ModalBottomWidgetState(
    isPursued: false,
    isActive: false,
    cpm: 0,
    trackBudget: false,
    minBudget: 0,
    trackcpm: false,
    minCpm: 0,
    notifications: {},
  );

  ModalBottomWidgetState get modalBottomState => _modalBottomState;

  // is active
  bool? _isActive;
  void setActive(bool value) {
    _modalBottomState = _modalBottomState.copyWith(
      isActive: value,
    );
    _isActive = value;
    notify();
  }

  bool get isActive => _isActive ?? false;

  // name
  String? _name;
  void setName(String value) {
    _name = value;
    notify();
  }

  String get name => _name ?? '';

  // is pursued
  bool? _isPursued;
  void setPursued(bool value) {
    _modalBottomState = _modalBottomState.copyWith(
      isPursued: value,
    );
    _isPursued = value;
    notify();
  }

  bool get isPursued => _isPursued ?? false;

  // notifications
  Map<String, double>? _notifications;
  void setNotifications(List<NotificationModel> value) {
    for (NotificationModel notification in value) {
      _notifications![notification.property] = notification.minValue ?? 0;
    }
    _modalBottomState = _modalBottomState.copyWith(
      notifications: notifications,
    );
    // _notifications = value;
    notify();
  }

  Map<String, double> get notifications => _notifications ?? {};

  // cpm
  int? _cpm;
  void setCpm(int value) {
    _modalBottomState = _modalBottomState.copyWith(
      cpm: value,
    );
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

  List<AutoStatModel> _autoStatList = [];
  void setAutoStatList(List<AutoStatModel> value) {
    _autoStatList = value;
    notify();
  }

  List<AutoStatModel> get autoStatList => _autoStatList;

  // PUBLIC METHODS ======================================================================== PUBLIC METHODS
  // saves changes from modal bottom widget to local storage and Wb API
  // updates screen
  Future<void> save(ModalBottomWidgetState state) async {
    final isActive = state.isActive;
    if (isActive != _isActive) {
      await changeActivity();
    }

    final isPursued = state.isPursued;
    if (isPursued != _isPursued) {
      await _changePursue();
    }

    final cpm = state.cpm;
    if (cpm != _cpm) {
      await _changeCpm(cpm);
    }

    final notifications = state.notifications;
    if (!mapEquals(notifications, _notifications)) {
      await _changeNotifications(notifications);
    }

    _asyncInit();
  }

  // Starts or stops advert
  Future<void> changeActivity() async {
    if (_isActive == null) {
      return;
    }
    if (_isActive!) {
      await _stop();
    } else {
      await _start();
    }
  }

  // PRIVATE METHODS ======================================================================== PRIVATE METHODS
  Future<void> _asyncInit() async {
    SqfliteService.printTableContent("auto_stat");
    SqfliteService.printTableContent("pursued");

    final values = await Future.wait([
      fetch(() => advertService.advertInfo(advertId)), // advertInfo
      fetch(() => advertService.isPursued(advertId)), // isPursued
      fetch(() => advertService.getBudget(advertId)), // budget
      fetch(() => autoStatService.getAll(advertId)), // autoStatList
      fetch(() => notificationService.getForParent(advertId)), // notification
    ]);

    // Advert Info
    final advertInfo = values[0] as Advert?;
    final isPursued = values[1] as bool?;
    final budget = values[2] as int?;
    final autoStatList = values[3] as List<AutoStatModel>?;
    final notificationList = values[4] as List<NotificationModel>?;
    if (advertInfo == null) {
      return;
    }
    setActive(advertInfo.status == 9);
    if (advertInfo.type == 8) {
      if (advertInfo is AdvertAutoModel &&
          advertInfo.autoParams != null &&
          advertInfo.autoParams!.cpm != null) {
        setCpm(advertInfo.autoParams!.cpm!);
        if (advertInfo.autoParams!.subject != null) {
          subjectId = advertInfo.autoParams!.subject!.id!;
        }
      }
    }

    setName(advertInfo.name);

    // Pursued
    if (isPursued == null) {
      return;
    }
    setPursued(isPursued);

    // Budget
    if (budget == null) {
      return;
    }
    setBudget(budget);

    // notification
    if (notificationList == null) {
      return;
    }
    setNotifications(notificationList);

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

  Future<void> _stop() async {
    final adv = await fetch(() => advertService.stopAdvert(advertId));
    if (adv == null || !adv) {
      // could not stop
      setActive(true); // still active
      return;
    }
    // done
    setActive(false); // now paused
    return;
  }

  // Pursue callback
  Future<void> _changePursue() async {
    if (_isPursued == null) {
      return;
    }
    if (_isPursued!) {
      await _untrack();
    } else {
      await _track();
    }

    final isPursued = await fetch(() => advertService.isPursued(advertId));
    if (isPursued == null) {
      return;
    }
    setPursued(isPursued);
  }

  Future<void> _track() async {
    final ok = await fetch(() => advertService.addToTrack(advertId));
    if (ok == null) {
      return;
    }
    setPursued(ok);
  }

  Future<void> _untrack() async {
    final ok = await fetch(() => advertService.deleteFromTrack(advertId));
    if (ok == null) {
      return;
    }
    setPursued(ok);
  }

  Future<void> _changeCpm(int cpm) async {
    if (_cpm == null) {
      return;
    }
    await fetch(() => advertService.setCpm(
        advertId: advertId, cpm: cpm, type: 8, param: subjectId));
  }

  Future<void> _changeNotifications(Map<String, double> notifications) async {
    if (_cpm == null) {
      return;
    }
    await fetch(() => advertService.setCpm(
        advertId: advertId, cpm: _cpm!, type: 8, param: subjectId));
  }

  Future<void> _saveNotification(String property, double minValue) {
    final newNotification = NotificationModel(
      parentId: advertId,
      property: property,
      minValue: minValue,
    );
    return fetch(() => notificationService.addNotification(newNotification));
  }

  Future<void> _deleteNotification(String property) {
    return fetch(() => notificationService.delete(advertId, property));
  }
}