import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/keyword.dart';
import 'package:rewild/domain/entities/search_campaign_stat.dart';

abstract class SingleSearchWordsKeywordService {
  Future<Resource<SearchCampaignStat>> getSearchCampaignStat(int campaignId);
  Future<Resource<bool>> setSearchExcluded(
      int campaignId, List<String> excluded);
}

abstract class SingleSearchWordsAdvertService {
  Future<Resource<Advert>> advertInfo(int campaignId);
}

class SingleSearchWordsViewModel extends ResourceChangeNotifier {
  final SingleSearchWordsKeywordService keywordService;
  final SingleSearchWordsAdvertService advertService;
  final int campaignId;
  SingleSearchWordsViewModel(this.campaignId,
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
      fetch(() => keywordService.getSearchCampaignStat(campaignId)),
      fetch(() => advertService.advertInfo(campaignId)),
    ]);

    // Advert Info
    final searchStatsWordRes = values[0] as SearchCampaignStat?;
    final advertInfo = values[1] as Advert?;
    if (searchStatsWordRes == null) {
      return;
    }

    searchStatsWordRes.words.keywords
        .sort((a, b) => a.count.compareTo(b.count));
    _keywords = searchStatsWordRes.words.keywords;
    _stat = searchStatsWordRes.stat;
    _excluded = searchStatsWordRes.words.excluded;
    _phrase = searchStatsWordRes.words.phrase;
    _pluse = searchStatsWordRes.words.pluse;
    _strong = searchStatsWordRes.words.strong;
    // Advert Info
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

  List<Stat> _stat = [];

  List<Stat> get stat => _stat;

  List<String> _excluded = [];

  List<String> get excluded => _excluded;

  List<String> _phrase = [];

  List<String> get phrase => _phrase;

  List<String> _pluse = [];

  List<String> get pluse => _pluse;

  List<String> _strong = [];

  List<String> get strong => _strong;

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
    await fetch(() => keywordService.setSearchExcluded(campaignId, _excluded));
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
