// Auto stat
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/domain/entities/auto_stat_word.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';

// Api key
abstract class AutoStatServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

abstract class AutoStatServiceAdvertApiClient {
  Future<Resource<AdvertStatModel>> getAutoStat(String token, int advertId);
  Future<Resource<AutoStatWord>> autoStatWords(String token, int advertId);
}

abstract class AutoStatServiceAdvertStatDataProvider {
  Future<Resource<List<AdvertStatModel>>> getAll(int advertId);
  Future<Resource<void>> save(AdvertStatModel autoStat);
}

class AutoAdvertService
    implements
        SingleAdvertStatsViewModelAdvertStatsService,
        SingleAutoWordsAutoStatsService {
  final AutoStatServiceAdvertStatDataProvider autoStatDataProvider;
  final AutoStatServiceAdvertApiClient advertApiClient;
  final AutoStatServiceApiKeyDataProvider apiKeysDataProvider;

  const AutoAdvertService({
    required this.autoStatDataProvider,
    required this.advertApiClient,
    required this.apiKeysDataProvider,
  });

  @override
  Future<Resource<List<AdvertStatModel>>> getAll(int advertId) async {
    // get all stored auto stats for the auto advert
    final storedAutoStatsResource = await autoStatDataProvider.getAll(advertId);
    if (storedAutoStatsResource is Error) {
      return Resource.error(
        storedAutoStatsResource.message!,
      );
    }
    if (storedAutoStatsResource is Empty) {
      return Resource.success([]);
    }
    return storedAutoStatsResource;
  }

  Resource<List<AdvertStatModel>> _filter(List<AdvertStatModel> stats) {
    final fullPeriod = stats.last.createdAt.difference(stats.last.createdAt);
    if (fullPeriod < const Duration(hours: 8)) {
      return Resource.success(stats);
    } else if (fullPeriod < const Duration(days: 1)) {
      return Resource.success(stats.sublist(0, stats.length - 2));
    }
    return Resource.success(stats.sublist(0, stats.length - 1));
  }

  @override
  Future<Resource<AdvertStatModel>> getCurrent(int advertId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // get current auto stat from API
    final currentAutoStatResource = await advertApiClient.getAutoStat(
      tokenResource.data!.token,
      advertId,
    );
    if (currentAutoStatResource is Error) {
      return Resource.error(currentAutoStatResource.message!);
    }

    return Resource.success(currentAutoStatResource.data!);
  }

  @override
  Future<Resource<AutoStatWord>> getAutoStatWords(int advertId) async {
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
      advertId,
    );
    if (currentAutoStatResource is Error) {
      return Resource.error(currentAutoStatResource.message!);
    }
    return Resource.success(currentAutoStatResource.data!);
  }
}
