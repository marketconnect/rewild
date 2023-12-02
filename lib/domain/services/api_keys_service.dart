import 'dart:async';

import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/presentation/add_api_keys_screen/add_api_keys_view_model.dart';

abstract class ApiKeysServiceApiKeysDataProvider {
  Future<Resource<List<ApiKeyModel>>> getAllApiKeys(List<String> types);
  Future<Resource<void>> addApiKey(ApiKeyModel card);
  Future<Resource<void>> deleteApiKey(String apiKeyType);
}

class ApiKeysService implements AddApiKeysScreenApiKeysService {
  final ApiKeysServiceApiKeysDataProvider apiKeysDataProvider;
  final StreamController<bool> apiKeyExistsStreamController;
  ApiKeysService(
      {required this.apiKeysDataProvider,
      required this.apiKeyExistsStreamController});
  @override
  Future<Resource<List<ApiKeyModel>>> getAll(List<String> types) async {
    final apiKeysResource = await apiKeysDataProvider.getAllApiKeys(types);
    if (apiKeysResource is Error) {
      return Resource.error(apiKeysResource.message!,
          source: runtimeType.toString(), name: "getAll", args: [types]);
    }
    if (apiKeysResource is Empty) {
      return Resource.success([]);
    }
    return Resource.success(apiKeysResource.data!);
  }

  @override
  Future<Resource<void>> deleteApiKey(String apiKeyType) async {
    final ok = await apiKeysDataProvider.deleteApiKey(apiKeyType);
    if (ok is Error) {
      return Resource.error(ok.message!,
          source: runtimeType.toString(),
          name: "deleteApiKey",
          args: [apiKeyType]);
    }
    if (apiKeyType == 'Продвижение') {
      apiKeyExistsStreamController.add(false);
    }
    return Resource.empty();
  }

  @override
  Future<Resource<void>> add(String key, String type) async {
    final apiKey = ApiKeyModel(
      token: key,
      type: type,
    );
    final ok = await apiKeysDataProvider.addApiKey(apiKey);
    if (ok is Error) {
      return Resource.error(ok.message!,
          source: runtimeType.toString(), name: "addApiKey", args: [key, type]);
    }
    if (type == 'Продвижение') {
      apiKeyExistsStreamController.add(true);
    }
    return Resource.empty();
  }
}
