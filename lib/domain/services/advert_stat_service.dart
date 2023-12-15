// Auto stat

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';

// Api key
abstract class AdvertStatServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getApiKey({required String type});
}

abstract class AdvertStatServiceAdvertApiClient {
  Future<Either<RewildError, AdvertStatModel>> getAutoStat(
      {required String token, required int campaignId});
}

abstract class AdvertStatServiceAdvertStatDataProvider {
  Future<Either<RewildError, List<AdvertStatModel>>> getAll(
      {required int campaignId, DateTime? from});
  Future<Either<RewildError, void>> save({required AdvertStatModel autoStat});
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
      {required int campaignId}) async {
    // get all stored auto stats for the auto advert
    return await autoStatDataProvider.getAll(
        campaignId: campaignId, from: yesterdayEndOfTheDay());
  }

  @override
  Future<Either<RewildError, AdvertStatModel>> getCurrent(
      {required String token, required int campaignId}) async {
    // get current auto stat from API
    return await advertApiClient.getAutoStat(
      token: token,
      campaignId: campaignId,
    );
  }
}
