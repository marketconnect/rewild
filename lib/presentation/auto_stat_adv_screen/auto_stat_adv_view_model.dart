import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/auto_stat.dart';

abstract class AutoStatViewModelAutoStatService {
  Future<Resource<AutoStatModel>> getCurrent(int advertId);
  Future<Resource<List<AutoStatModel>>> getAll(int advertId);
}

abstract class AutoStatViewModelAdvertService {
  Future<Resource<int>> getBudget(int advertId);
  Future<Resource<bool>> isPursued(int advertId);
  Future<Resource<bool>> addToTrack(int advertId);
  Future<Resource<bool>> deleteFromTrack(int advertId);
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

  // is pursued
  bool? _isPursued;
  void setPursued(bool value) {
    _isPursued = value;
    notify();
  }

  bool get isPursued => _isPursued ?? false;

  // budget
  int? _budget;
  void setBudget(int value) {
    _budget = value;
    notify();
  }

  int get budget => _budget ?? 0;
  // date and time of a momment when budget will be spent
  String? _spentTime;
  void setSpentTime(String value) {
    _spentTime = value;
    notify();
  }

  String get spentTime => _spentTime ?? "";

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
    if (autoStatList == null) {
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

    // final spentTimeDiff = autoStatList[autoStatList.length - 1]
    //     .createdAt
    //     .difference(autoStatList[0].createdAt)
    //     .inSeconds;
    // if (spentTimeDiff > 3600) {
    //   setSpentTime('${spentTimeDiff ~/ 3600}ч ${spentTimeDiff % 60}м');
    // } else if (spentTimeDiff > 60) {
    //   setSpentTime('${spentTimeDiff ~/ 60}м ${spentTimeDiff % 60}с');
    // } else {
    //   setSpentTime('${spentTimeDiff % 60}с');
    // }
    // final flCh = calculateAverageViewsPerMinute(
    //     autoStatList.sublist(autoStatList.length - 8, autoStatList.length - 1));
    // print(
    //     'flCh.length: ${flCh.length} autoStatList length: ${autoStatList.length}');
    // setViewsChart(flCh);
  }

  Future<void> track() async {
    final ok = await fetch(() => advertService.addToTrack(advertId));
    if (ok == null) {
      return;
    }
    setPursued(ok);
  }

  Future<void> untrack() async {
    final ok = await fetch(() => advertService.deleteFromTrack(advertId));
    if (ok == null) {
      return;
    }
    setPursued(ok);
  }
}
