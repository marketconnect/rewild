import 'package:rewild/core/utils/api_duration_constants.dart';
import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/auto_campaign_stat.dart';
import 'package:rewild/domain/entities/keyword.dart';
import 'package:rewild/domain/entities/search_campaign_stat.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild/presentation/single_search_words_screen%20copy/single_search_words_view_model.dart';

// Api key
abstract class KeywordsServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

// api client
abstract class KeywordsServiceAdvertApiClient {
  Future<Resource<AutoCampaignStatWord>> autoStatWords(
      String token, int campaignId);
  Future<Resource<SearchCampaignStat>> getSearchStat(
      String token, int campaignId);
  Future<Resource<bool>> setAutoSetExcluded(
      String token, int campaignId, List<String> excludedKw);
}

// data provider
abstract class KeywordsServiceKeywordsDataProvider {
  Future<Resource<List<Keyword>>> getAll(int campaignId);
  Future<Resource<bool>> save(Keyword keyword);
}

class KeywordsService
    implements SingleAutoWordsKeywordService, SingleSearchWordsKeywordService {
  final KeywordsServiceApiKeyDataProvider apiKeysDataProvider;
  final KeywordsServiceAdvertApiClient advertApiClient;
  final KeywordsServiceKeywordsDataProvider keywordsDataProvider;
  KeywordsService({
    required this.apiKeysDataProvider,
    required this.advertApiClient,
    required this.keywordsDataProvider,
  });

  DateTime? autoExcludedLastReq;

  @override
  Future<Resource<bool>> setAutoExcluded(
      int campaignId, List<String> excluded) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // request to API
    if (autoExcludedLastReq != null) {
      await ApiDurationConstants.ready(autoExcludedLastReq,
          ApiDurationConstants.autoSetExcludedDurationBetweenReqInMs);
    }

    final autoExcludedResource = await advertApiClient.setAutoSetExcluded(
        tokenResource.data!.token, campaignId, excluded);
    autoExcludedLastReq = DateTime.now();
    if (autoExcludedResource is Error) {
      return Resource.error(autoExcludedResource.message!);
    }
    return Resource.success(autoExcludedResource.data!);
  }

  @override
  Future<Resource<AutoCampaignStatWord>> getAutoStatWords(
      int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // get current auto stat from API
    final currentAutoStatResource = await advertApiClient.autoStatWords(
      tokenResource.data!.token,
      campaignId,
    );
    if (currentAutoStatResource is Error) {
      return Resource.error(currentAutoStatResource.message!);
    }

    // get saved auto stat from DB
    final keywordsResource = await keywordsDataProvider.getAll(campaignId);
    if (keywordsResource is Error) {
      return Resource.error(keywordsResource.message!);
    }

    final autoStat = currentAutoStatResource.data!;

    final currentKeywords = autoStat.keywords
        .map((e) => Keyword(
              keyword: e.keyword,
              count: e.count,
              campaignId: campaignId,
            ))
        .toList();

    final savedKeywords = keywordsResource.data!
        .map((e) => Keyword(
              keyword: e.keyword,
              count: e.count,
              campaignId: campaignId,
            ))
        .toList();

    List<Keyword> newKeywords = [];
    for (var keyword in currentKeywords) {
      // the keyword does not exist in DB
      if (!savedKeywords.any((e) => e.keyword == keyword.keyword)) {
        newKeywords.add(keyword);
        // save in database
        final saveResource = await keywordsDataProvider.save(keyword);
        if (saveResource is Error) {
          return Resource.error(saveResource.message!);
        }
        continue;
      }

      // keyword exists in DB
      keyword.setNotNew();
      final savedKeyword =
          savedKeywords.firstWhere((e) => e.keyword == keyword.keyword);

      // saved keyword count is different
      if (savedKeyword.count != keyword.count) {
        // set diff property
        keyword.setDiff(savedKeyword.count);
        // update in database
        final saveResource = await keywordsDataProvider.save(keyword);
        if (saveResource is Error) {
          return Resource.error(saveResource.message!);
        }
      }

      newKeywords.add(keyword);
    }

    final newAutoStat = autoStat.copyWith(keywords: newKeywords);

    return Resource.success(newAutoStat);
  }

  @override
  Future<Resource<SearchCampaignStat>> getSearchCampaignStat(
      int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // get current auto stat from API
    final currentSearchStatResource = await advertApiClient.getSearchStat(
      tokenResource.data!.token,
      campaignId,
    );
    if (currentSearchStatResource is Error) {
      return Resource.error(currentSearchStatResource.message!);
    }

    // get saved auto stat from DB
    final keywordsResource = await keywordsDataProvider.getAll(campaignId);
    if (keywordsResource is Error) {
      return Resource.error(keywordsResource.message!);
    }

    final searchStat = currentSearchStatResource.data!;

    final currentKeywords = searchStat.words.keywords
        .map((e) => Keyword(
              keyword: e.keyword,
              count: e.count,
              campaignId: campaignId,
            ))
        .toList();

    final savedKeywords = keywordsResource.data!
        .map((e) => Keyword(
              keyword: e.keyword,
              count: e.count,
              campaignId: campaignId,
            ))
        .toList();

    List<Keyword> newKeywords = [];
    for (var keyword in currentKeywords) {
      // the keyword does not exist in DB
      if (!savedKeywords.any((e) => e.keyword == keyword.keyword)) {
        newKeywords.add(keyword);
        // save in database
        final saveResource = await keywordsDataProvider.save(keyword);
        if (saveResource is Error) {
          return Resource.error(saveResource.message!);
        }
        continue;
      }

      // keyword exists in DB
      keyword.setNotNew();
      final savedKeyword =
          savedKeywords.firstWhere((e) => e.keyword == keyword.keyword);

      // saved keyword count is different
      if (savedKeyword.count != keyword.count) {
        // set diff property
        keyword.setDiff(savedKeyword.count);
        // update in database
        final saveResource = await keywordsDataProvider.save(keyword);
        if (saveResource is Error) {
          return Resource.error(saveResource.message!);
        }
      }

      newKeywords.add(keyword);
    }

    final oldWords = searchStat.words;

    final newWords = oldWords.copyWith(keywords: newKeywords);

    final newSearchStat = searchStat.copyWith(words: newWords);

    return Resource.success(newSearchStat);
  }
}
