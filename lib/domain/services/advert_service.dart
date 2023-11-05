import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/advert_base.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/presentation/all_adverts_screen/all_adverts_screen_view_model.dart';

abstract class AdvertServiceAdvertApiClient {
  Future<Resource<List<AdvertInfoModel>>> getAdverts(String token);
  Future<Resource<Advert>> getAdvertInfo(String token, int id);
}

abstract class AdvertServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

class AdvertService implements AllAdvertsScreenAdvertService {
  final AdvertServiceAdvertApiClient advertApiClient;
  final AdvertServiceApiKeyDataProvider apiKeysDataProvider;

  AdvertService(
      {required this.advertApiClient, required this.apiKeysDataProvider});

  @override
  Future<Resource<bool>> apiKeyExists() async {
    final resource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (resource is Error) {
      return Resource.error(resource.message!);
    }
    if (resource is Empty) {
      return Resource.success(false);
    }
    return Resource.success(true);
  }

  @override
  Future<Resource<List<Advert>>> getAll() async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    final advertsResource =
        await advertApiClient.getAdverts(tokenResource.data!.token);
    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!);
    }

    List<Advert> res = [];
    for (var advert in advertsResource.data!) {
      if (advert.status == 7 || advert.status == 8) {
        continue;
      }

      await Future.delayed(Duration(milliseconds: 300));

      final advInfoResource = await advertApiClient.getAdvertInfo(
          tokenResource.data!.token, advert.advertId);
      if (advInfoResource is Error) {
        print("ERROR");
        return Resource.error(advInfoResource.message!);
      }
      res.add(advInfoResource.data!);
    }
    return Resource.success(res);
  }
}
