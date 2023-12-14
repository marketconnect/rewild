import 'dart:async';

import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/presentation/add_api_keys_screen/add_api_keys_view_model.dart';

abstract class ApiKeysServiceApiKeysDataProvider {
  Future<Either<RewildError, List<ApiKeyModel>>> getAllApiKeys(
      List<String> types);
  Future<Either<RewildError, void>> addApiKey(ApiKeyModel card);
  Future<Either<RewildError, void>> deleteApiKey(String apiKeyType);
}

class ApiKeysService implements AddApiKeysScreenApiKeysService {
  final ApiKeysServiceApiKeysDataProvider apiKeysDataProvider;
  final StreamController<Map<ApiKeyType, bool>> apiKeyExistsStreamController;
  ApiKeysService(
      {required this.apiKeysDataProvider,
      required this.apiKeyExistsStreamController});
  @override
  Future<Either<RewildError, List<ApiKeyModel>>> getAll(
      List<String> types) async {
    final apiKeysResource = await apiKeysDataProvider.getAllApiKeys(types);
    if (apiKeysResource is Error) {
      return left(RewildError(apiKeysResource.message!,
          source: runtimeType.toString(), name: "getAll", args: [types]);
    }
    if (apiKeysResource is Empty) {
      return right([]);
    }
    return right(apiKeysResource.data!);
  }

  @override
  Future<Either<RewildError, void>> deleteApiKey(String apiKeyType) async {
    final ok = await apiKeysDataProvider.deleteApiKey(apiKeyType);
    if (ok is Error) {
      return left(RewildError(ok.message!,
          source: runtimeType.toString(),
          name: "deleteApiKey",
          args: [apiKeyType]);
    }
    if (apiKeyType == StringConstants.apiKeyTypes[ApiKeyType.promo]!) {
      apiKeyExistsStreamController.add({ApiKeyType.promo: false});
    }

    if (apiKeyType == StringConstants.apiKeyTypes[ApiKeyType.question]!) {
      apiKeyExistsStreamController.add({ApiKeyType.question: false});
    }

    return right(null);
  }

  @override
  Future<Either<RewildError, void>> add(String key, String type) async {
    final apiKey = ApiKeyModel(
      token: key,
      type: type,
    );
    final ok = await apiKeysDataProvider.addApiKey(apiKey);
    if (ok is Error) {
      return left(RewildError(ok.message!,
          source: runtimeType.toString(), name: "addApiKey", args: [key, type]);
    }
    if (type == StringConstants.apiKeyTypes[ApiKeyType.promo]!) {
      apiKeyExistsStreamController.add({ApiKeyType.promo: true});
    }
    if (type == StringConstants.apiKeyTypes[ApiKeyType.question]!) {
      apiKeyExistsStreamController.add({ApiKeyType.question: true});
    }
    return right(null);
  }
}
