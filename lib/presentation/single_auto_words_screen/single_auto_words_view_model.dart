import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/auto_campaign_stat.dart';
import 'package:rewild/domain/entities/keyword.dart';

abstract class SingleAutoWordsKeywordService {
  Future<Either<RewildError, AutoCampaignStatWord>> getAutoStatWords(
      {required String token, required int campaignId});
  Future<Either<RewildError, String?>> getToken();
  Future<Either<RewildError, bool>> setAutoExcluded(
      {required String token,
      required int campaignId,
      required List<String> excluded});
}

abstract class SingleAutoWordsAdvertService {
  Future<Either<RewildError, Advert>> getAdvert(
      {required String token, required int campaignId});
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
    // SqfliteService.printTableContent("keywords");
    await _update();
  }

  Future<void> _update() async {
    final apiKey = await fetch(() => keywordService.getToken());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);
    final values = await Future.wait([
      fetch(() => keywordService.getAutoStatWords(
          token: apiKey, campaignId: campaignId)),
      fetch(
          () => advertService.getAdvert(token: apiKey, campaignId: campaignId)),
    ]);

    // Advert Info
    final autoStatsWordRes = values[0] as AutoCampaignStatWord?;
    final advertInfo = values[1] as Advert?;
    if (autoStatsWordRes == null) {
      return;
    }

    _clusterKeywordsByNormQuery(autoStatsWordRes.keywords);

    autoStatsWordRes.keywords.sort((a, b) => b.count.compareTo(a.count));

    final tempKeywords = autoStatsWordRes.keywords;
    _keywords = [
      ...tempKeywords.where((element) => element.isNew),
      ...tempKeywords.where((element) => !element.isNew),
    ];
    _excluded = autoStatsWordRes.excluded;
    if (advertInfo == null) {
      return;
    }
    _name = advertInfo.name;
    // print('keywords: ${_keywords.length}');
    notify();
  }

  // Api Key
  String? _apiKey;
  String? get apiKey => _apiKey;
  void setApiKey(String? apiKey) {
    _apiKey = apiKey;
    notify();
  }

  // Clusters
  Map<String, List<Keyword>> _keywordClusters = {};
  Map<String, List<Keyword>> get keywordClusters => _keywordClusters;
  // New method to cluster keywords
  void _clusterKeywordsByNormQuery(List<Keyword> keywords) {
    _keywordClusters = {};
    for (var keyword in keywords) {
      _keywordClusters.putIfAbsent(keyword.normquery, () => []).add(keyword);
    }
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
    if (_apiKey == null) {
      return;
    }
    await fetch(() => keywordService.setAutoExcluded(
        token: _apiKey!, campaignId: campaignId, excluded: _excluded));
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
