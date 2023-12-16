import 'dart:async';

import 'package:fpdart/fpdart.dart';
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
  final StreamController<Map<ApiKeyType, String>> apiKeyExistsStreamController;
  ApiKeysService(
      {required this.apiKeysDataProvider,
      required this.apiKeyExistsStreamController});

  @override
  Future<Either<RewildError, List<ApiKeyModel>>> getAll(
      {required List<String> types}) async {
    final apiKeysResult = await apiKeysDataProvider.getAllApiKeys(types);
    return apiKeysResult;
  }

  // Function to delete api key and update stream
  @override
  Future<Either<RewildError, void>> deleteApiKey(
      {required String apiKeyType}) async {
    final deleteResult = await apiKeysDataProvider.deleteApiKey(apiKeyType);
    if (deleteResult.isLeft()) {
      return deleteResult;
    }

    if (apiKeyType == StringConstants.apiKeyTypes[ApiKeyType.promo]!) {
      apiKeyExistsStreamController.add({ApiKeyType.promo: ""});
    }

    if (apiKeyType == StringConstants.apiKeyTypes[ApiKeyType.question]!) {
      apiKeyExistsStreamController.add({ApiKeyType.question: ""});
    }

    return right(null);
  }

  // Function to add api key and update stream
  @override
  Future<Either<RewildError, void>> add(
      {required String key, required String type}) async {
    final apiKey = ApiKeyModel(
      token: key,
      type: type,
    );
    final addApiKeyResult = await apiKeysDataProvider.addApiKey(apiKey);
    return addApiKeyResult.fold((l) => left(l), (r) {
      if (type == StringConstants.apiKeyTypes[ApiKeyType.promo]!) {
        apiKeyExistsStreamController.add({ApiKeyType.promo: key});
      }
      if (type == StringConstants.apiKeyTypes[ApiKeyType.question]!) {
        apiKeyExistsStreamController.add({ApiKeyType.question: key});
      }
      return right(null);
    });
  }
}
