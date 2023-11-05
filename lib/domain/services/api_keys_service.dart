import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/presentation/api_keys_screen/api_keys_view_model.dart';

abstract class ApiKeysServiceApiKeysDataProvider {
  Future<Resource<List<ApiKeyModel>>> getAllApiKeys(List<String> types);
  Future<Resource<void>> addApiKey(ApiKeyModel card);
  Future<Resource<void>> deleteApiKey(String apiKeyType);
}

class ApiKeysService implements ApiKeysScreenApiKeysService {
  final ApiKeysServiceApiKeysDataProvider apiKeysDataProvider;
  ApiKeysService({required this.apiKeysDataProvider});
  @override
  Future<Resource<List<ApiKeyModel>>> getAll(List<String> types) async {
    final apiKeysResource = await apiKeysDataProvider.getAllApiKeys(types);
    if (apiKeysResource is Error) {
      return Resource.error(apiKeysResource.message!);
    }
    if (apiKeysResource is Empty) {
      return Resource.success([]);
    }
    return Resource.success(apiKeysResource.data!);
  }

  @override
  Future<Resource<void>> deleteApiKey(String apiKeyType) async {
    return await apiKeysDataProvider.deleteApiKey(apiKeyType);
  }

  @override
  Future<Resource<void>> add(String key, String type) async {
    final apiKey = ApiKeyModel(
      token: key,
      type: type,
    );
    return await apiKeysDataProvider.addApiKey(apiKey);
  }
}
