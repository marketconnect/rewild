import 'package:flutter/material.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/api_key_model.dart';

abstract class AddApiKeysScreenApiKeysService {
  Future<Resource<List<ApiKeyModel>>> getAll(List<String> types);
  Future<Resource<void>> add(String key, String type);
  Future<Resource<void>> deleteApiKey(String apiKeyType);
}

class AddApiKeysScreenViewModel extends ResourceChangeNotifier {
  final AddApiKeysScreenApiKeysService apiKeysService;
  AddApiKeysScreenViewModel({
    required super.context,
    required this.apiKeysService,
    required super.internetConnectionChecker,
  }) {
    _asyncInit();
  }

  List<ApiKeyModel> _apiKeys = [];
  void setApiKeys(List<ApiKeyModel> apiKeys) {
    _apiKeys = apiKeys;
    notify();
  }

  List<ApiKeyModel> get apiKeys => _apiKeys;

  final Map<ApiKeyType, String> _types = StringConstants.apiKeyTypes;
  List<String> get types => _types.entries.map((e) => e.value).toList();

  List<String> _addedTypes = [];
  void setAddedTypes(List<String> addedTypes) {
    _addedTypes = addedTypes;
  }

  List<String> get addedTypes => _addedTypes;

  void _asyncInit() async {
    final fetchedApiKeys = await fetch(() => apiKeysService.getAll(types));
    if (fetchedApiKeys == null) {
      return;
    }

    setApiKeys(fetchedApiKeys);
    _addedTypes.clear();
    for (final apiKey in fetchedApiKeys) {
      _addedTypes.add(apiKey.type);
    }
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
