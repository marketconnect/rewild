import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/auto_campaign_stat.dart';
import 'package:rewild/domain/entities/keyword.dart';

abstract class SingleAutoWordsKeywordService {
  Future<Resource<AutoCampaignStatWord>> getAutoStatWords(int campaignId);
  Future<Resource<bool>> setAutoExcluded(int campaignId, List<String> excluded);
}

abstract class SingleAutoWordsAdvertService {
  Future<Resource<Advert>> advertInfo(int campaignId);
}

class SingleAutoWordsViewModel extends ResourceChangeNotifier {
  final SingleAutoWordsKeywordService keywordService;
  final SingleAutoWordsAdvertService advertService;
  final int campaignId;
  SingleAutoWordsViewModel(this.campaignId,
      {required super.context,
      required super.internetConnectionChecker,
      required this.advertService,
      required this.keywordService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    await _update();
  }

  Future<void> _update() async {
    final values = await Future.wait([
      fetch(() => keywordService.getAutoStatWords(campaignId)),
      fetch(() => advertService.advertInfo(campaignId)),
    ]);

    // Advert Info
    final autoStatsWordRes = values[0] as AutoCampaignStatWord?;
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
    _keywords.insert(
        0, Keyword(campaignId: campaignId, keyword: word, count: 1));
    change(word);

    notify();
  }

  Future<void> save() async {
    await fetch(() => keywordService.setAutoExcluded(campaignId, _excluded));
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
