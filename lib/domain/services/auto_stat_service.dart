// Auto stat
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/auto_stat.dart';
import 'package:rewild/presentation/auto_advert_screen/auto_advert_view_model.dart';

// Api key
abstract class AutoStatServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

abstract class AutoStatServiceAdvertApiClient {
  Future<Resource<AutoStatModel>> getAutoStat(String token, int advertId);
}

abstract class AutoStatServiceAutoStatDataProvider {
  Future<Resource<List<AutoStatModel>>> getAll(int advertId);
  Future<Resource<void>> save(AutoStatModel autoStat);
}

class AutoAdvertService implements AutoAdvertViewModelAutoAdvertService {
  final AutoStatServiceAutoStatDataProvider autoStatDataProvider;
  final AutoStatServiceAdvertApiClient advertApiClient;
  final AutoStatServiceApiKeyDataProvider apiKeysDataProvider;

  const AutoAdvertService({
    required this.autoStatDataProvider,
    required this.advertApiClient,
    required this.apiKeysDataProvider,
  });

  @override
  Future<Resource<List<AutoStatModel>>> getAll(int advertId) async {
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

  @override
  Future<Resource<AutoStatModel>> getCurrent(int advertId) async {
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
}
