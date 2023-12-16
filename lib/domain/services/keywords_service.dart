import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';

import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/auto_campaign_stat.dart';
import 'package:rewild/domain/entities/keyword.dart';
import 'package:rewild/domain/entities/search_campaign_stat.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild/presentation/single_search_words_screen/single_search_words_view_model.dart';

// Api key
abstract class KeywordsServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getApiKey({required String type});
}

// api client
abstract class KeywordsServiceAdvertApiClient {
  Future<Either<RewildError, AutoCampaignStatWord>> autoStatWords(
      {required String token, required int campaignId});
  Future<Either<RewildError, SearchCampaignStat>> getSearchStat(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> setAutoSetExcluded(
      {required String token,
      required int campaignId,
      required List<String> excludedKw});
  Future<Either<RewildError, bool>> setSearchExcludedKeywords(
      {required String token,
      required int campaignId,
      required List<String> excludedKeywords});
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
  Future<Either<RewildError, String?>> getToken() async {
    final tokenEither =
        await apiKeysDataProvider.getApiKey(type: 'Продвижение');

    return tokenEither.fold((l) => left(l), (apiKeyModel) async {
      if (apiKeyModel == null) {
        return right(null);
      }
      return right(apiKeyModel.token);
    });
  }

  @override
  Future<Either<RewildError, bool>> setAutoExcluded(
      {required String token,
      required int campaignId,
      required List<String> excluded}) async {
    // TODO "Продвижение"

    final autoExcludedEither = await advertApiClient.setAutoSetExcluded(
        token: token, campaignId: campaignId, excludedKw: excluded);
    return autoExcludedEither.fold((l) => left(l), (r) => right(r));
  }

  @override
  Future<Either<RewildError, AutoCampaignStatWord>> getAutoStatWords(
      {required String token, required int campaignId}) async {
    // get current auto stat from API
    final currentAutoStatEither = await advertApiClient.autoStatWords(
        token: token, campaignId: campaignId);

    return currentAutoStatEither.fold((l) => left(l), (autoStat) async {
      // get saved auto stat from DB
      final keywordsEither = await keywordsDataProvider.getAll(campaignId);
      return keywordsEither.fold((l) => left(l), (keywords) async {
        final currentKeywords = autoStat.keywords
            .map((e) => Keyword(
                  keyword: e.keyword,
                  count: e.count,
                  campaignId: campaignId,
                ))
            .toList();
        final savedKeywords = keywords
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
            final saveEither = await keywordsDataProvider.save(keyword);
            if (saveEither.isLeft()) {
              return Left(saveEither.fold(
                  (err) => err, (r) => throw UnimplementedError()));
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
            final saveEither = await keywordsDataProvider.save(keyword);
            if (saveEither.isLeft()) {
              return Left(saveEither.fold(
                  (err) => err, (r) => throw UnimplementedError()));
            }
            continue;
          }

          newKeywords.add(keyword);
        }
        final newAutoStat = autoStat.copyWith(keywords: newKeywords);

        return right(newAutoStat);
      });
    });
  }

  // search
  @override
  Future<Either<RewildError, bool>> setSearchExcluded(
      {required String token,
      required int campaignId,
      required List<String> excluded}) async {
    final searchExcludedEither =
        await advertApiClient.setSearchExcludedKeywords(
            token: token, campaignId: campaignId, excludedKeywords: excluded);
    return searchExcludedEither.fold((l) => left(l), (r) => right(r));
  }

  @override
  Future<Either<RewildError, SearchCampaignStat>> getSearchCampaignStat(
      {required String token, required int campaignId}) async {
    // get current auto stat from API
    final currentSearchStatEither = await advertApiClient.getSearchStat(
      token: token,
      campaignId: campaignId,
    );
    return currentSearchStatEither.fold((l) => left(l), (searchStat) async {
      final keywordsEither = await keywordsDataProvider.getAll(campaignId);

      return keywordsEither.fold((l) => left(l), (keywords) async {
        final currentKeywords = searchStat.words.keywords
            .map((e) => Keyword(
                  keyword: e.keyword,
                  count: e.count,
                  campaignId: campaignId,
                ))
            .toList();
        final savedKeywords = keywords
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
            final saveEither = await keywordsDataProvider.save(keyword);
            if (saveEither.isLeft()) {
              return Left(saveEither.fold(
                  (err) => err, (r) => throw UnimplementedError()));
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
            final saveEither = await keywordsDataProvider.save(keyword);
            if (saveEither.isLeft()) {
              return Left(saveEither.fold(
                  (err) => err, (r) => throw UnimplementedError()));
            }
          }

          newKeywords.add(keyword);
        }

        final oldWords = searchStat.words;

        final newWords = oldWords.copyWith(keywords: newKeywords);

        final newSearchStat = searchStat.copyWith(words: newWords);

        return right(newSearchStat);
      });
    });
  }
}
