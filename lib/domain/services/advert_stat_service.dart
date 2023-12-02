// Auto stat
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';

// Api key
abstract class AdvertStatServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

abstract class AdvertStatServiceAdvertApiClient {
  Future<Resource<AdvertStatModel>> getAutoStat(String token, int campaignId);
}

abstract class AdvertStatServiceAdvertStatDataProvider {
  Future<Resource<List<AdvertStatModel>>> getAll(int campaignId,
      [DateTime? from]);
  Future<Resource<void>> save(AdvertStatModel autoStat);
}

class AdvertStatService
    implements SingleAdvertStatsViewModelAdvertStatsService {
  final AdvertStatServiceAdvertStatDataProvider autoStatDataProvider;
  final AdvertStatServiceAdvertApiClient advertApiClient;
  final AdvertStatServiceApiKeyDataProvider apiKeysDataProvider;

  const AdvertStatService({
    required this.autoStatDataProvider,
    required this.advertApiClient,
    required this.apiKeysDataProvider,
  });

  // returns all saved today's auto stats
  @override
  Future<Resource<List<AdvertStatModel>>> getTodays(int campaignId) async {
    // get all stored auto stats for the auto advert
    final storedAutoStatsResource =
        await autoStatDataProvider.getAll(campaignId, yesterdayEndOfTheDay());
    if (storedAutoStatsResource is Error) {
      return Resource.error(
        storedAutoStatsResource.message!,
        source: runtimeType.toString(),
        name: "getTodays",
        args: [campaignId],
      );
    }
    if (storedAutoStatsResource is Empty) {
      return Resource.success([]);
    }
    return storedAutoStatsResource;
  }

  @override
  Future<Resource<AdvertStatModel>> getCurrent(int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(),
          name: "getCurrent",
          args: [campaignId]);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // get current auto stat from API
    final currentAutoStatResource = await advertApiClient.getAutoStat(
      tokenResource.data!.token,
      campaignId,
    );
    if (currentAutoStatResource is Error) {
      return Resource.error(currentAutoStatResource.message!,
          source: runtimeType.toString(),
          name: "getCurrent",
          args: [campaignId]);
    }

    return Resource.success(currentAutoStatResource.data!);
  }
}
