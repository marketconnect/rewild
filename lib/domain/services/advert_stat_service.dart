// Auto stat

import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';

// Api key
abstract class AdvertStatServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel>> getApiKey(String type);
}

abstract class AdvertStatServiceAdvertApiClient {
  Future<Either<RewildError, AdvertStatModel>> getAutoStat(
      String token, int campaignId);
}

abstract class AdvertStatServiceAdvertStatDataProvider {
  Future<Either<RewildError, List<AdvertStatModel>>> getAll(int campaignId,
      [DateTime? from]);
  Future<Either<RewildError, void>> save(AdvertStatModel autoStat);
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
  Future<Either<RewildError, List<AdvertStatModel>>> getTodays(
      int campaignId) async {
    // get all stored auto stats for the auto advert
    final storedAutoStatsResource =
        await autoStatDataProvider.getAll(campaignId, yesterdayEndOfTheDay());
    if (storedAutoStatsResource is Error) {
      return left(RewildError(
        storedAutoStatsResource.message!,
        source: runtimeType.toString(),
        name: "getTodays",
        args: [campaignId],
      );
    }
    if (storedAutoStatsResource is Empty) {
      return right([]);
    }
    return storedAutoStatsResource;
  }

  @override
  Future<Either<RewildError, AdvertStatModel>> getCurrent(
      int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: "getCurrent",
          args: [campaignId]);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    // get current auto stat from API
    final currentAutoStatResource = await advertApiClient.getAutoStat(
      tokenResource.data!.token,
      campaignId,
    );
    if (currentAutoStatResource is Error) {
      return left(RewildError(currentAutoStatResource.message!,
          source: runtimeType.toString(),
          name: "getCurrent",
          args: [campaignId]);
    }

    return right(currentAutoStatResource.data!);
  }
}
