import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/auto_stat_word.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';

// Api key
abstract class KeywordsServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

abstract class KeywordsServiceAdvertApiClient {
  Future<Resource<AutoStatWord>> autoStatWords(String token, int campaignId);
}

class KeywordsService implements SingleAutoWordsKeywordService {
  final KeywordsServiceApiKeyDataProvider apiKeysDataProvider;
  final KeywordsServiceAdvertApiClient advertApiClient;
  const KeywordsService({
    required this.apiKeysDataProvider,
    required this.advertApiClient,
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
    return Resource.success(currentAutoStatResource.data!);
  }
}
