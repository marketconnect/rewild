import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/advert_base.dart';

import 'package:rewild/domain/entities/auto_stat_word.dart';
import 'package:rewild/domain/entities/keyword.dart';

abstract class SingleAutoWordsAutoStatsService {
  Future<Resource<AutoStatWord>> getAutoStatWords(int advertId);
}

abstract class SingleAutoWordsAdvertService {
  Future<Resource<Advert>> advertInfo(int advertId);
  Future<Resource<bool>> setAutoExcluded(int advertId, List<String> excluded);
  Future<Resource<bool>> setCpm(
      {required int advertId,
      required int type,
      required int cpm,
      required int param,
      int? instrument});
}

class SingleAutoWordsViewModel extends ResourceChangeNotifier {
  final SingleAutoWordsAutoStatsService autoStatsService;
  final SingleAutoWordsAdvertService advertService;
  final int advertId;
  SingleAutoWordsViewModel(this.advertId,
      {required super.context,
      required super.internetConnectionChecker,
      required this.advertService,
      required this.autoStatsService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    await _update();
  }

  Future<void> _update() async {
    final values = await Future.wait([
      fetch(() => autoStatsService.getAutoStatWords(advertId)),
      fetch(() => advertService.advertInfo(advertId)),
    ]);

    // Advert Info
    final autoStatsWordRes = values[0] as AutoStatWord?;
    final advertInfo = values[1] as Advert?;
    if (autoStatsWordRes == null) {
      return;
    }

    autoStatsWordRes.keywords.sort((a, b) => a.count.compareTo(b.count));
    _keywords = autoStatsWordRes.keywords;
    _excluded = autoStatsWordRes.excluded;
    if (advertInfo == null) {
      return;
    }
    _name = advertInfo.name;
    _setTitleCpm(advertInfo);
    notify();
  }

  void _setTitleCpm(Advert advertInfo) {
    switch (advertInfo.type) {
      case AdvertTypeConstants.auto:
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
      default:
        break;
    }
  }

  // for change cpm
  int subjectId = 0;
  int? _advType;

  // CPM
  int? _cpm;
  void setCpm(int value) {
    print("SETCPM $value");
    _cpm = value;
    notify();
  }

  int? get cpm => _cpm;

  // Name
  String? _name;
  String? get name => _name ?? '';

  List<Keyword> _keywords = [];

  List<Keyword> get keywords => _keywords;

  List<String> _excluded = [];

  List<String> get excluded => _excluded;

  List<String> _changes = [];
  void setChanges(List<String> changes) {
    _changes = changes;
  }

  void change(String word) {
    if (_changes.contains(word)) {
      _changes.remove(word);
    } else {
      _changes.add(word);
    }
    notify();
  }

  bool get hasChanges => _changes.isNotEmpty;

  void moveToExcluded(String word) {
    keywords.removeWhere((element) => element.keyword == word);
    excluded.add(word);
    change(word);

    notify();
  }

  void moveToKeywords(String word) {
    _excluded.removeWhere((element) => element == word);
    _keywords.insert(0, Keyword(keyword: word, count: 1));
    change(word);

    notify();
  }

  Future<void> save() async {
    await fetch(() => advertService.setAutoExcluded(advertId, _excluded));
  }

  // Search functionality
  bool _searchInputOpen = false;
  bool get searchInputOpen => _searchInputOpen;
  void toggleSearchInput() {
    _searchInputOpen = !_searchInputOpen;
    _searchQuery = "";
    notify();
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearchQuery(String query) {
    _searchQuery = query;

    notify();
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
    await fetch(() => advertService.setCpm(
        advertId: advertId, cpm: cpm, type: _advType!, param: subjectId));
    await _update();
  }
}
