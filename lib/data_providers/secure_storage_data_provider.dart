import 'dart:math';
import 'package:android_id/android_id.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/services/advert_service.dart';
import 'package:rewild/domain/services/api_keys_service.dart';
import 'package:rewild/domain/services/auth_service.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rewild/domain/services/advert_stat_service.dart';
import 'package:rewild/domain/services/keywords_service.dart';
import 'package:rewild/domain/services/question_service.dart';
import 'package:rewild/domain/services/review_service.dart';

class SecureStorageProvider
    implements
        AuthServiceSecureDataProvider,
        KeywordsServiceApiKeyDataProvider,
        ApiKeysServiceApiKeysDataProvider,
        AdvertStatServiceApiKeyDataProvider,
        QuestionServiceApiKeyDataProvider,
        ReviewServiceApiKeyDataProvider,
        AdvertServiceApiKeyDataProvider {
  static const _secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ));

  //  AndroidOptions _getAndroidOptions() => const AndroidOptions(
  //       encryptedSharedPreferences: true,
  //     );

  const SecureStorageProvider();

  @override
  Future<Resource<void>> updateUsername(
      {String? username,
      String? token,
      String? expiredAt,
      bool? freebie}) async {
    if (username != null) {
      final resource = await _write(key: 'username', value: username);
      if (resource is Error) {
        return resource;
      }
    }

    if (token != null) {
      final resource = await _write(key: 'token', value: token);
      if (resource is Error) {
        return resource;
      }
    }
    if (expiredAt != null) {
      final resource = _write(key: 'token_expired_at', value: expiredAt);
      if (resource is Error) {
        return resource;
      }
    }
    if (freebie != null) {
      final resource = _write(key: 'freevie', value: freebie ? "1" : "");
      if (resource is Error) {
        return resource;
      }
    }
    return Resource.empty();
  }

  @override
  Future<Resource<String>> getToken() async {
    // read token from local storage
    final resource = await _read(key: 'token');
    if (resource is Error) {
      return Resource.error(
        resource.message!,
        source: runtimeType.toString(),
        name: "getToken",
      );
    }
    String? token = resource.data;
    if (token == null) {
      return Resource.empty();
    }

    return Resource.success(token);
  }

  @override
  Future<Resource<bool>> tokenNotExpiredInThreeMinutes() async {
    final resource = await _read(key: 'token_expired_at');
    if (resource is Error) {
      return Resource.error(
        resource.message!,
        source: runtimeType.toString(),
        name: 'tokenNotExpiredInThreeMinutes',
      );
    }
    String? expiredAt = resource.data;
    if (expiredAt == null) {
      return Resource.error(
        'No token expiration data',
        source: runtimeType.toString(),
        name: 'tokenNotExpiredInThreeMinutes',
      );
    }
    final now = DateTime.now().add(const Duration(minutes: 3));
    final timestamp = int.parse(expiredAt);

    final expiredAtDT = DateTime.fromMicrosecondsSinceEpoch(timestamp);

    return Resource.success(
      expiredAtDT.isAfter(now),
    );
  }

  @override
  Future<Resource<String>> getUsername() async {
    // May be deviceId already exists
    final resource = await _read(key: 'username');
    if (resource is Error) {
      return Resource.error(
        resource.message!,
        source: runtimeType.toString(),
        name: 'getUsername',
      );
    }
    String? deviceId = resource.data;

    // If not
    if (deviceId == null) {
      try {
        const androidId = AndroidId();
        deviceId = await androidId.getId();
        // If AndroidId returns null
        deviceId ??= getRandomString(10);
        // Save username

        await updateUsername(username: deviceId);
      } on Exception catch (e) {
        return Resource.error(
          e.toString(),
          source: runtimeType.toString(),
          name: 'getUsername',
          args: [],
        );
      }
    }
    return Resource.success(deviceId);
  }

  @override
  Future<Resource<ApiKeyModel>> getApiKey(String type) async {
    final resource = await _read(key: type);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(), name: 'getApiKey', args: [type]);
    }

    if (resource.data == null) {
      return Resource.empty();
    }

    return Resource.success(ApiKeyModel(token: resource.data!, type: type));
  }

  @override
  Future<Resource<List<ApiKeyModel>>> getAllApiKeys(List<String> types) async {
    List<ApiKeyModel> apiKeys = [];
    for (final type in types) {
      final resource = await _read(key: type);
      if (resource is Error) {
        return Resource.error(resource.message!,
            source: runtimeType.toString(),
            name: 'getAllApiKeys',
            args: [types]);
      }
      if (resource is Success) {
        final apiKey = ApiKeyModel(token: resource.data!, type: type);
        apiKeys.add(apiKey);
      }
    }
    return Resource.success(apiKeys);
  }

  @override
  Future<Resource<void>> addApiKey(ApiKeyModel apiKey) async {
    return await _write(key: apiKey.type, value: apiKey.token);
  }

  @override
  Future<Resource<void>> deleteApiKey(String apiKeyType) async {
    await _secureStorage.delete(
        key: apiKeyType,
        aOptions: const AndroidOptions(encryptedSharedPreferences: true));

    return Resource.empty();
  }

  Future<Resource<void>> _write(
      {required String key, required String? value}) async {
    try {
      await _secureStorage.write(
          key: key,
          value: value,
          aOptions: const AndroidOptions(
            encryptedSharedPreferences: true,
          ));
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "could not write to secure storage: $e",
        source: runtimeType.toString(),
        name: '_write',
        args: [key, value],
      );
    }
  }

  String getRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // STATIC METHODS ========================================================== STATIC METHODS
  static Future<Resource<String?>> _read({required String key}) async {
    try {
      final value = await _secureStorage.read(
          key: key,
          aOptions: const AndroidOptions(
            encryptedSharedPreferences: true,
          ));
      if (value == null) {
        return Resource.empty();
      }
      return Resource.success(value);
    } catch (e) {
      return Resource.error(
        "could not read from secure storage: $e",
        source: "SecureStorageDataProvider",
        name: '_read',
        args: [key],
      );
    }
  }

  static Future<Resource<ApiKeyModel>> getApiKeyInBackground(
      String type) async {
    final resource = await _read(key: type);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: "SecureStorageDataProvider", name: 'getApiKey', args: [type]);
    }

    if (resource.data == null) {
      return Resource.empty();
    }

    return Resource.success(ApiKeyModel(token: resource.data!, type: type));
  }

  static Future<Resource<ApiKeyModel>> getApiKeyFromBackground(
      String type) async {
    final resource = await _read(key: type);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: "SecureStorageDataProvider", name: 'getApiKey', args: [type]);
    }

    if (resource.data == null) {
      return Resource.empty();
    }

    return Resource.success(ApiKeyModel(token: resource.data!, type: type));
  }
}
