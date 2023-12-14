import 'package:rewild/core/utils/rewild_error.dart';

import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/auto_campaign_stat.dart';
import 'package:rewild/domain/entities/keyword.dart';
import 'package:rewild/domain/entities/search_campaign_stat.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild/presentation/single_search_words_screen/single_search_words_view_model.dart';

// Api key
abstract class KeywordsServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel>> getApiKey(String type);
}

// api client
abstract class KeywordsServiceAdvertApiClient {
  Future<Either<RewildError, AutoCampaignStatWord>> autoStatWords(
      String token, int campaignId);
  Future<Either<RewildError, SearchCampaignStat>> getSearchStat(
      String token, int campaignId);
  Future<Either<RewildError, bool>> setAutoSetExcluded(
      String token, int campaignId, List<String> excludedKw);
  Future<Either<RewildError, bool>> setSearchExcludedKeywords(
      String token, int campaignId, List<String> excludedKeywords);
}

// data provider
abstract class KeywordsServiceKeywordsDataProvider {
  Future<Either<RewildError, List<Keyword>>> getAll(int campaignId);
  Future<Either<RewildError, bool>> save(Keyword keyword);
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

  @override
  Future<Either<RewildError, bool>> setAutoExcluded(
      int campaignId, List<String> excluded) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: 'setAutoExcluded',
          args: [campaignId, excluded]);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    final autoExcludedResource = await advertApiClient.setAutoSetExcluded(
        tokenResource.data!.token, campaignId, excluded);

    if (autoExcludedResource is Error) {
      return left(RewildError(autoExcludedResource.message!,
          source: runtimeType.toString(),
          name: 'setAutoExcluded',
          args: [campaignId, excluded]);
    }
    return right(autoExcludedResource.data!);
  }

  @override
  Future<Either<RewildError, AutoCampaignStatWord>> getAutoStatWords(
      int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: 'getAutoStatWords',
          args: [campaignId]);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    // get current auto stat from API
    final currentAutoStatResource = await advertApiClient.autoStatWords(
      tokenResource.data!.token,
      campaignId,
    );
    if (currentAutoStatResource is Error) {
      return left(RewildError(currentAutoStatResource.message!,
          source: runtimeType.toString(),
          name: 'getAutoStatWords',
          args: [campaignId]);
    }

    // get saved auto stat from DB
    final keywordsResource = await keywordsDataProvider.getAll(campaignId);
    if (keywordsResource is Error) {
      return left(RewildError(keywordsResource.message!,
          source: runtimeType.toString(),
          name: 'getAutoStatWords',
          args: [campaignId]);
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
          return left(RewildError(saveResource.message!,
              source: runtimeType.toString(),
              name: 'getAutoStatWords',
              args: [campaignId]);
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
          return left(RewildError(saveResource.message!,
              source: runtimeType.toString(),
              name: 'getAutoStatWords',
              args: [campaignId]);
        }
      }

      newKeywords.add(keyword);
    }

    final newAutoStat = autoStat.copyWith(keywords: newKeywords);

    return right(newAutoStat);
  }

  // search
  @override
  Future<Either<RewildError, bool>> setSearchExcluded(
      int campaignId, List<String> excluded) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: 'setAutoExcluded',
          args: [campaignId, excluded]);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    final searchExcludedResource =
        await advertApiClient.setSearchExcludedKeywords(
            tokenResource.data!.token, campaignId, excluded);

    if (searchExcludedResource is Error) {
      return left(RewildError(searchExcludedResource.message!,
          source: runtimeType.toString(),
          name: 'setAutoExcluded',
          args: [campaignId, excluded]);
    }
    return right(searchExcludedResource.data!);
  }

  @override
  Future<Either<RewildError, SearchCampaignStat>> getSearchCampaignStat(
      int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: 'getSearchCampaignStat',
          args: [campaignId]);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    // get current auto stat from API
    final currentSearchStatResource = await advertApiClient.getSearchStat(
      tokenResource.data!.token,
      campaignId,
    );
    if (currentSearchStatResource is Error) {
      return left(RewildError(currentSearchStatResource.message!,
          source: runtimeType.toString(),
          name: 'getSearchCampaignStat',
          args: [campaignId]);
    }

    // get saved auto stat from DB
    final keywordsResource = await keywordsDataProvider.getAll(campaignId);
    if (keywordsResource is Error) {
      return left(RewildError(keywordsResource.message!,
          source: runtimeType.toString(),
          name: 'getSearchCampaignStat',
          args: [campaignId]);
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
          return left(RewildError(saveResource.message!,
              source: runtimeType.toString(),
              name: 'getSearchCampaignStat',
              args: [campaignId]);
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
          return left(RewildError(saveResource.message!,
              source: runtimeType.toString(),
              name: 'getSearchCampaignStat',
              args: [campaignId]);
        }
      }

      newKeywords.add(keyword);
    }

    final oldWords = searchStat.words;

    final newWords = oldWords.copyWith(keywords: newKeywords);

    final newSearchStat = searchStat.copyWith(words: newWords);

    return right(newSearchStat);
  }
}
