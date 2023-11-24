import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/auto_stat_word.dart';
import 'package:rewild/domain/entities/keyword.dart';

abstract class AutoStatsWordsAutoStatsService {
  Future<Resource<AutoStatWord>> getAutoStatWords(int advertId);
}

abstract class AutoStatsWordsAdvertService {
  Future<Resource<Advert>> advertInfo(int advertId);
  Future<Resource<bool>> setAutoExcluded(int advertId, List<String> excluded);
}

class AutoStatsWordsViewModel extends ResourceChangeNotifier {
  final AutoStatsWordsAutoStatsService autoStatsWordsAutoStatsService;
  final AutoStatsWordsAdvertService autoStatsWordsAdvertService;
  final int advertId;
  AutoStatsWordsViewModel(this.advertId,
      {required super.context,
      required super.internetConnectionChecker,
      required this.autoStatsWordsAdvertService,
      required this.autoStatsWordsAutoStatsService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    final values = await Future.wait([
      fetch(() => autoStatsWordsAutoStatsService.getAutoStatWords(advertId)),
      fetch(() => autoStatsWordsAdvertService.advertInfo(advertId)),
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

    notify();
  }

  // Name
  String? _name;
  String? get name => _name ?? '';

  List<Keyword> _keywords = [];

  List<Keyword> get keywords => _keywords;

  List<String> _excluded = [];

  List<String> get excluded => _excluded;

  void moveToExcluded(String word) {
    keywords.removeWhere((element) => element.keyword == word);
    excluded.add(word);
    notify();
  }

  void moveToKeywords(String word) {
    _excluded.removeWhere((element) => element == word);
    _keywords.insert(0, Keyword(keyword: word, count: 1));
    notify();
  }

  Future<void> save() async {
    await fetch(
        () => autoStatsWordsAdvertService.setAutoExcluded(advertId, _excluded));
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
}
