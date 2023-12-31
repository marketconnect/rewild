import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/core/utils/text_filed_validator.dart';
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/advert_card_model.dart';
import 'package:rewild/domain/entities/advert_catalogue_model.dart';
import 'package:rewild/domain/entities/advert_recomendation_model.dart';
import 'package:rewild/domain/entities/advert_search_model.dart';
import 'package:rewild/domain/entities/advert_search_plus_catalogue_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/domain/entities/stream_notification_event.dart';
import 'package:rewild/presentation/notification_advert_screen/notification_advert_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/my_dialog_textfield_radio.dart';
import 'package:rewild/widgets/my_dialog_textfield_radio_checkbox.dart';

import '../../domain/entities/advert_base.dart';

abstract class SingleAdvertStatsViewModelAdvertStatsService {
  Future<Either<RewildError, AdvertStatModel>> getCurrent(
      {required String token, required int campaignId});
  Future<Either<RewildError, List<AdvertStatModel>>> getTodays(
      {required int campaignId});
}

abstract class SingleAdvertStatsViewModelAdvertService {
  Future<Either<RewildError, int>> getBudget(
      {required String token, required int campaignId});
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, Advert>> getAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> checkAdvertIsActive(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> stopAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId});

  Future<Either<RewildError, bool>> setCpm(
      {required String token,
      required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument});
}

abstract class SingleAdvertStatsViewModelNotificationService {
  Future<Either<RewildError, bool>> checkForParent({required int campaignId});
}

class SingleAdvertStatsViewModel extends ResourceChangeNotifier {
  final SingleAdvertStatsViewModelAdvertStatsService advertStatService;
  final SingleAdvertStatsViewModelAdvertService advertService;
  final SingleAdvertStatsViewModelNotificationService notificationService;
  final int campaignId;
  // Stream
  Stream<StreamNotificationEvent> streamNotification;
  SingleAdvertStatsViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.advertStatService,
    required this.advertService,
    required this.streamNotification,
    required this.notificationService,
    required this.campaignId,
  }) {
    _asyncInit();
  }

  // FIELDS =============================================================== FIELDS
  // ApiKey
  String? _apiKey;
  void setApiKey(String value) {
    _apiKey = value;
    notify();
  }

  // Change cpm Dialog widget
  Widget? changeCpmDialog;

  void setChangeCpmDialog(Widget widget) {
    changeCpmDialog = widget;
  }

  bool _tracked = false;

  void setTracked() {
    _tracked = true;
    notify();
  }

  void setUntracked() {
    _tracked = false;
    notify();
  }

  bool get tracked => _tracked;

  // for change cpm in
  // Map<int, String>? textInputOptions;
  int? _advType;
  // for In Catalogue
  // int? _setId;

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

  // For catalog
  List<AdvertCatalogueParam> _params = [];
  void setParams(List<AdvertCatalogueParam> value) {
    _params = value;
    notify();
  }

  List<AdvertCatalogueParam> get params => _params;

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

  Future<void> _asyncInit() async {
    // Stream update track
    streamNotification.listen((event) async {
      if (event.parentType == ParentType.card) {
        if (event.exists) {
          setTracked();
        } else {
          setUntracked();
        }
      }
    });
    SqfliteService.printTableContent("notifications");

    await _update();
  }

  Future<void> _update() async {
    final apiKey = await fetch(() => advertService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);
    final values = await Future.wait([
      fetch(() => advertService.getAdvert(
          token: apiKey, campaignId: campaignId)), // advertInfo
      fetch(() => advertService.getBudget(
          token: apiKey, campaignId: campaignId)), // budget
      fetch(() =>
          advertStatService.getTodays(campaignId: campaignId)), // autoStatList
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

    // Notification
    final notificationsExists = await fetch(
        () => notificationService.checkForParent(campaignId: campaignId));
    if (notificationsExists != null && notificationsExists) {
      setTracked();
    }
  }

  // asyncInit finished ==========================================================================================
  void _setTitleCpm(Advert advertInfo) {
    _advType = advertInfo.type;
    Map<int, String> textInputOptions = {};
    Map<int, String> radioOptions = {};
    switch (advertInfo.type) {
      case AdvertTypeConstants.auto:
        setTitle("Авто");
        if (advertInfo is AdvertAutoModel &&
            advertInfo.autoParams != null &&
            advertInfo.autoParams!.cpm != null) {
          setCpm(advertInfo.autoParams!.cpm!);
          final cpm = advertInfo.autoParams!.cpm;
          if (advertInfo.autoParams!.subject != null) {
            final subjectId = advertInfo.autoParams!.subject!.id!;
            final subjectName = advertInfo.autoParams!.subject!.name!;
            textInputOptions[subjectId] = "$cpm₽";
            radioOptions[subjectId] = subjectName;
          }
        }
        break;
      case AdvertTypeConstants.inSearch:
        setTitle("В поиске");

        if (advertInfo is AdvertSearchModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          setCpm(advertInfo.params!.first.price!);
          if (advertInfo.params != null) {
            final params = advertInfo.params;
            for (final param in params!) {
              if (param.subjectId != null) {
                final subjectId = param.subjectId!;
                final subjectName = param.subjectName ?? "";
                final cpm = param.price;
                textInputOptions[subjectId] = "$cpm₽";
                radioOptions[subjectId] = subjectName;
              }
            }
          }
        }
        break;
      case AdvertTypeConstants.inCard:
        setTitle("В карточке");
        if (advertInfo is AdvertCardModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null &&
            advertInfo.params!.first.setId != null) {
          setCpm(advertInfo.params!.first.price!);
          final params = advertInfo.params;
          for (final param in params!) {
            if (param.setId != null) {
              final setId = param.setId!;
              final setName = param.setName ?? "";
              final cpm = param.price;
              textInputOptions[setId] = "$cpm₽";
              radioOptions[setId] = setName;
            }
          }
        }
        break;
      case AdvertTypeConstants.inCatalog:
        setTitle("В каталоге");
        if (advertInfo is AdvertCatalogueModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          for (var param in advertInfo.params!) {
            radioOptions[param.menuId!] = param.menuName!;
            textInputOptions[param.menuId!] = '${param.price!}₽';
          }

          setCpm(advertInfo.params!.first.price!);
          if (advertInfo.params!.first.menuId != null) {
            setChangeCpmDialog(MyDialogTextFieldRadio(
              header: "Ставка (СРМ, ₽)",
              addGroup: _changeCpm,
              radioOptions: radioOptions,
              textInputOptions: textInputOptions,
              validator: TextFieldValidator.isNumericAndGreaterThanN,
              btnText: "Обновить",
              description: "Введите новое значение ставки",
              keyboardType: TextInputType.number,
            ));
          }
        }

        break;

      case AdvertTypeConstants.inRecomendation:
        setTitle("В рекомендациях");
        if (advertInfo is AdvertRecomendaionModel &&
            advertInfo.params != null &&
            advertInfo.params!.first.price != null) {
          for (var param in advertInfo.params!) {
            radioOptions[param.subjectId!] = param.subjectName!;
            textInputOptions[param.subjectId!] = '${param.price!}₽';
          }
          setCpm(advertInfo.params!.first.price!);
        }

        break;
      case AdvertTypeConstants.searchPlusCatalog:
        setTitle("В поиске и каталоге");
        if (advertInfo is AdvertSearchPlusCatalogueModel &&
            advertInfo.unitedParams != null &&
            advertInfo.unitedParams!.first.catalogCPM != null) {
          setCpm(advertInfo.unitedParams!.first.catalogCPM!);
          final params = advertInfo.unitedParams!;
          final Map<int, String> checkBoxOptions = {};
          for (final param in params) {
            checkBoxOptions[param.subject!.id!] = param.subject!.name!;
          }
          textInputOptions[4] = "${params.first.catalogCPM!}₽";
          textInputOptions[6] = "${params.first.searchCPM!}₽";
          radioOptions[4] = "Каталог";
          radioOptions[6] = "Поиск";

          setChangeCpmDialog(MyDialogTextFieldRadioCheckBox(
            header: "Ставка (СРМ, ₽)",
            checkBoxOptions: checkBoxOptions,
            radioOptions: radioOptions,
            textInputOptions: textInputOptions,
            addGroup: _changeCpmInSearchAndCatalog,
            validator: TextFieldValidator.isNumericAndGreaterThanN,
            btnText: "Обновить",
            description: "Введите новое значение ставки",
            keyboardType: TextInputType.number,
          ));
        }

        break;
    }
    if (textInputOptions.keys.isNotEmpty &&
        _advType != AdvertTypeConstants.searchPlusCatalog) {
      setChangeCpmDialog(MyDialogTextFieldRadio(
        header: "Ставка (СРМ, ₽)",
        textInputOptions: textInputOptions,
        radioOptions: radioOptions,
        addGroup: _changeCpm,
        validator: TextFieldValidator.isNumericAndGreaterThanN,
        btnText: "Обновить",
        description: "Введите новое значение ставки",
        keyboardType: TextInputType.number,
      ));
    }
  }

  Future<void> _changeCpm({required String value, required int option}) async {
    final cpm = int.tryParse(value) ?? 0;

    if (_cpm == null || _advType == null) {
      return;
    }
    if (_apiKey == null) {
      return;
    }
    await fetch(() => advertService.setCpm(
        token: _apiKey!,
        campaignId: campaignId,
        cpm: cpm,
        type: _advType!,
        param: option));

    await _update();
  }

  Future<void> _changeCpmInSearchAndCatalog(
      {required String value,
      required int option,
      required int option1}) async {
    final cpm = int.tryParse(value) ?? 0;
    if (_cpm == null || _advType == null) {
      return;
    }
    await fetch(() => advertService.setCpm(
        token: _apiKey!,
        campaignId: campaignId,
        cpm: cpm,
        type: _advType!,
        param: option1,
        instrument: option));

    await _update();
  }

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
    if (_apiKey == null) {
      return;
    }
    final adv = await fetch(() =>
        advertService.startAdvert(token: _apiKey!, campaignId: campaignId));
    final checkAdv = await fetch(() => advertService.checkAdvertIsActive(
        token: _apiKey!, campaignId: campaignId));
    if (checkAdv == null || adv == null || !adv) {
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
      nmId: campaignId,
      budget: budget,
    );

    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.advertNotificationScreen,
        arguments: state);
  }
}
