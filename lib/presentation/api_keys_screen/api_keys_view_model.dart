import 'package:flutter/material.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/api_key_model.dart';

abstract class ApiKeysScreenApiKeysService {
  Future<Resource<List<ApiKeyModel>>> getAll(List<String> types);
  Future<Resource<void>> add(String key, String type);
  Future<Resource<void>> deleteApiKey(String apiKeyType);
}

class ApiKeysScreenViewModel extends ResourceChangeNotifier {
  final ApiKeysScreenApiKeysService apiKeysService;
  ApiKeysScreenViewModel(
      {required super.context, required this.apiKeysService}) {
    _asyncInit();
  }

  List<ApiKeyModel> _apiKeys = [];
  void setApiKeys(List<ApiKeyModel> apiKeys) {
    _apiKeys = apiKeys;
    notify();
  }

  List<ApiKeyModel> get apiKeys => _apiKeys;

  final List<String> _types = StringConstants.apiKeyTypes;
  List<String> get types => _types;
  void _asyncInit() async {
    final fetchedApiKeys = await fetch(() => apiKeysService.getAll(_types));
    if (fetchedApiKeys == null) {
      return;
    }

    setApiKeys(fetchedApiKeys);
  }

  Future<void> add(String key, String type) async {
    await fetch(() => apiKeysService.add(key, type));
    if (context.mounted) {
      Navigator.pop(context);
    }
    _asyncInit();
  }

  Future<void> delete() async {
    for (int index = 0; index < _apiKeys.length; index++) {
      if (_apiKeys[index].isSelected) {
        await fetch(() => apiKeysService.deleteApiKey(_apiKeys[index].type));
      }
    }

    _asyncInit();
  }

  void select(int index) {
    _apiKeys[index].toggleSelected();
    notify();
  }
}
