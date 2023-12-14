import 'dart:math';
import 'package:android_id/android_id.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
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
  Future<Either<RewildError, void>> updateUsername(
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
    return right(null);
  }

  @override
  Future<Either<RewildError, String?>> getToken() async {
    // read token from local storage
    final resource = await _read(key: 'token');
    if (resource.isLeft()) {
      return resource;
    }
    final r = resource.getRight();
    String? token = r.getOrElse(() => null);
    if (token == null) {
      return right(null);
    }

    return right(token);
  }

  @override
  Future<Either<RewildError, bool>> tokenNotExpiredInThreeMinutes() async {
    final result = await _read(key: 'token_expired_at');
    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return left(RewildError(
          'No token expiration data',
          source: runtimeType.toString(),
          name: 'tokenNotExpiredInThreeMinutes',
        ));
      }
      final now = DateTime.now().add(const Duration(minutes: 3));
      final timestamp = int.parse(r);
       final expiredAtDT = DateTime.fromMicrosecondsSinceEpoch(timestamp);
       return right(
         expiredAtDT.isAfter(now),
       );
    },);
  }

  @override
  Future<Either<RewildError, String>> getUsername() async {
    // May be deviceId already exists
    final result = await _read(key: 'username');
    return result.fold((l) => left(l), (r) async {
      if (r == null) {
        try {
          const androidId = AndroidId();
          String? deviceId = await androidId.getId();
          // If AndroidId returns null
          deviceId ??= getRandomString(10);
          // Save username
          await updateUsername(username: deviceId);
          return right(deviceId);
        } on Exception catch (e) {
          return left(RewildError(
            e.toString(),
            source: runtimeType.toString(),
            name: 'getUsername',
            args: [],
          ));
        }
      }
      return right(r);
    });
  }

  @override
  Future<Either<RewildError, ApiKeyModel?>> getApiKey(String type) async {
    final result = await _read(key: type);

    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return right(null);
      }  
    return right(ApiKeyModel(token: r, type: type));
    });


  }

  @override
  Future<Either<RewildError, List<ApiKeyModel>>> getAllApiKeys(
      List<String> types) async {
    List<ApiKeyModel> apiKeys = [];
    for (final type in types) {
      final resource = await _read(key: type);
      if (resource is Error) {
        return left(RewildError(resource.message!,
            source: runtimeType.toString(),
            name: 'getAllApiKeys',
            args: [types]);
      }
      if (resource is Success) {
        final apiKey = ApiKeyModel(token: resource.data!, type: type);
        apiKeys.add(apiKey);
      }
    }
    return right(apiKeys);
  }

  @override
  Future<Either<RewildError, void>> addApiKey(ApiKeyModel apiKey) async {
    return await _write(key: apiKey.type, value: apiKey.token);
  }

  @override
  Future<Either<RewildError, void>> deleteApiKey(String apiKeyType) async {
    await _secureStorage.delete(
        key: apiKeyType,
        aOptions: const AndroidOptions(encryptedSharedPreferences: true));

    return right(null);
  }

  Future<Either<RewildError, void>> _write(
      {required String key, required String? value}) async {
    try {
      await _secureStorage.write(
          key: key,
          value: value,
          aOptions: const AndroidOptions(
            encryptedSharedPreferences: true,
          ));
      return right(null);
    } catch (e) {
      return left(RewildError(
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
  static Future<Either<RewildError, String?>> _read(
      {required String key}) async {
    try {
      final value = await _secureStorage.read(
          key: key,
          aOptions: const AndroidOptions(
            encryptedSharedPreferences: true,
          ));
      if (value == null) {
        return right(null);
      }
      return right(value);
    } catch (e) {
      return Either.left(RewildError(
        "could not read from secure storage: $e",
        source: "SecureStorageDataProvider",
        name: '_read',
        args: [key],
      ));
    }
  }

  static Future<Either<RewildError, ApiKeyModel>> getApiKeyInBackground(
      String type) async {
    final either = await _read(key: type);
    if (either.isLeft()) {
      return left(RewildError(resource.message!,
          source: "SecureStorageDataProvider", name: 'getApiKey', args: [type]));
    }

    if (resource.data == null) {
      return right(null);
    }

    return right(ApiKeyModel(token: resource.data!, type: type));
  }

  static Future<Either<RewildError, ApiKeyModel>> getApiKeyFromBackground(
      String type) async {
    final resource = await _read(key: type);
    if (resource is Error) {
      return left(RewildError(resource.message!,
          source: "SecureStorageDataProvider", name: 'getApiKey', args: [type]);
    }

    if (resource.data == null) {
      return right(null);
    }

    return right(ApiKeyModel(token: resource.data!, type: type));
  }
}
