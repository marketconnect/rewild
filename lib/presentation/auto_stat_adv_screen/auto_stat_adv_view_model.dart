import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/auto_stat.dart';
import 'package:rewild/presentation/auto_stat_adv_screen/widgets/modal_bottom_widget.dart';

import '../../domain/entities/advert_base.dart';

abstract class AutoStatViewModelAutoStatService {
  Future<Resource<AutoStatModel>> getCurrent(int advertId);
  Future<Resource<List<AutoStatModel>>> getAll(int advertId);
}

abstract class AutoStatViewModelAdvertService {
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

class AutoStatViewModel extends ResourceChangeNotifier {
  final AutoStatViewModelAutoStatService autoStatService;
  final AutoStatViewModelAdvertService advertService;
  final int advertId;
  AutoStatViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.autoStatService,
    required this.advertService,
    required this.advertId,
  }) {
    _asyncInit();
  }

  // for change cpm
  int subjectId = 0;

  // modal bottom state
  // is pursued
  ModalBottomWidgetState _modalBottomState = ModalBottomWidgetState(
    isPursued: false,
    isActive: false,
    cpm: 0,
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
  // date and time of a momment when budget will be spent
  // String? _spentTime;
  // void setSpentTime(String value) {
  //   _spentTime = value;
  //   notify();
  // }

  // String get spentTime => _spentTime ?? "";

  // views
  int? _views;
  void setViews(int value) {
    _views = value;
    notify();
  }

  int get views => _views ?? 0;

  // ctr
  double? _ctr;
  void setCtr(double value) {
    _ctr = value;
    notify();
  }

  double get ctr => _ctr ?? 0;

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

  Future<void> _asyncInit() async {
    SqfliteService.printTableContent("auto_stat");
    SqfliteService.printTableContent("pursued");
    final advertInfo = await fetch(() => advertService.advertInfo(advertId));
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

    final isPursued = await fetch(() => advertService.isPursued(advertId));
    if (isPursued == null) {
      return;
    }
    setPursued(isPursued);

    // BackgroundService.addAutoAdvert(advertId);
    final budget = await fetch(() => advertService.getBudget(advertId));
    if (budget == null) {
      return;
    }
    setBudget(budget);
    // final all
    final autoStatList = await fetch(() => autoStatService.getAll(advertId));
    if (autoStatList == null || autoStatList.isEmpty) {
      return;
    }
    autoStatList.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    setAutoStatList(autoStatList);
    // views
    final viewsDiff =
        autoStatList[autoStatList.length - 1].views - autoStatList[0].views;
    setViews(viewsDiff);

    final ctr = autoStatList[autoStatList.length - 1].ctr;
    setCtr(ctr);
    // ctr diff
    final ctrDiff =
        autoStatList[autoStatList.length - 1].ctr - autoStatList[0].ctr;
    setCtrDiff(ctrDiff);

    // cpc
    final cpc = autoStatList[autoStatList.length - 1].cpc;
    setCpc(cpc);

    // cpc diff
    final cpcDiff =
        autoStatList[autoStatList.length - 1].cpc - autoStatList[0].cpc;
    setCpcDiff(cpcDiff);

    // spent money
    final spentMoneyDiff =
        autoStatList[autoStatList.length - 1].spend - autoStatList[0].spend;

    setSpentMoney('${spentMoneyDiff.toStringAsFixed(0)}₽');
  }

  Future<void> save(ModalBottomWidgetState state) async {
    final isActive = state.isActive;
    if (isActive != _isActive) {
      await changeActivity();
    }

    final isPursued = state.isPursued;
    if (isPursued != _isPursued) {
      await changePursue();
    }

    final cpm = state.cpm;
    if (cpm != _cpm) {
      await changeCpm(cpm);
    }

    _asyncInit();
  }

  // Cpm callback
  Future<void> changeCpm(int cpm) async {
    if (_cpm == null) {
      return;
    }
    await fetch(() => advertService.setCpm(
        advertId: advertId, cpm: cpm, type: 8, param: subjectId));
  }

  // Activity callback
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
  Future<void> changePursue() async {
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
}
