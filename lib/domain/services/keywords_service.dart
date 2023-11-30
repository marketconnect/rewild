import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/auto_stat_word.dart';
import 'package:rewild/domain/entities/keyword.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';

// Api key
abstract class KeywordsServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

// api client
abstract class KeywordsServiceAdvertApiClient {
  Future<Resource<AutoStatWord>> autoStatWords(String token, int campaignId);
}

// data provider
abstract class KeywordsServiceKeywordsDataProvider {
  Future<Resource<List<Keyword>>> getAll(int campaignId);
  Future<Resource<bool>> save(Keyword keyword);
}

class KeywordsService implements SingleAutoWordsKeywordService {
  final KeywordsServiceApiKeyDataProvider apiKeysDataProvider;
  final KeywordsServiceAdvertApiClient advertApiClient;
  final KeywordsServiceKeywordsDataProvider keywordsDataProvider;
  const KeywordsService({
    required this.apiKeysDataProvider,
    required this.advertApiClient,
    required this.keywordsDataProvider,
  });
  @override
  Future<Resource<AutoStatWord>> getAutoStatWords(int campaignId) async {
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
}
