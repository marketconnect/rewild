import 'package:android_id/android_id.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/strings_utils.dart';
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

  const SecureStorageProvider();

  // Function to update user-related data (e.g., username, token, etc.) in secure storage
  @override
  Future<Either<RewildError, void>> updateUsername(
      {String? username,
      String? token,
      String? expiredAt,
      bool? freebie}) async {
    if (username != null) {
      final result = await _write(key: 'username', value: username);
      if (result.isLeft()) {
        return result;
      }
    }

    if (token != null) {
      final result = await _write(key: 'token', value: token);
      if (result.isLeft()) {
        return result;
      }
    }
    if (expiredAt != null) {
      final result = await _write(key: 'token_expired_at', value: expiredAt);
      if (result.isLeft()) {
        return result;
      }
    }
    if (freebie != null) {
      final result = await _write(key: 'freevie', value: freebie ? "1" : "");
      if (result.isLeft()) {
        return result;
      }
    }
    return right(null);
  }

  // Function to read token from secure storage
  @override
  Future<Either<RewildError, String?>> getToken() async {
    // read token from local storage
    final result = await _read(key: 'token');
    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return right('');
      }
      return right(r);
    });
  }

  // Function to check if token is expired
  @override
  Future<Either<RewildError, bool>> tokenNotExpiredInThreeMinutes() async {
    final result = await _read(key: 'token_expired_at');
    return result.fold(
      (l) => left(l),
      (r) {
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
      },
    );
  }

  // Function to get username
  @override
  Future<Either<RewildError, String?>> getUsername() async {
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

  // Function to get an API key of a specific type
  @override
  Future<Either<RewildError, ApiKeyModel?>> getApiKey(
      {required String type}) async {
    final result = await _read(key: type);

    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return right(null);
      }
      return right(ApiKeyModel(token: r, type: type));
    });
  }

  // Function to get all API keys of specific types
  @override
  Future<Either<RewildError, List<ApiKeyModel>>> getAllApiKeys(
      List<String> types) async {
    List<ApiKeyModel> apiKeys = [];
    for (final type in types) {
      final result = await _read(key: type);
      result.fold((l) => left(l), (r) {
        if (r != null) {
          final apiKey = ApiKeyModel(token: r, type: type);
          apiKeys.add(apiKey);
        }
      });
    }
    return right(apiKeys);
  }

  @override
  Future<Either<RewildError, void>> addApiKey(ApiKeyModel apiKey) async {
    return await _write(key: apiKey.type, value: apiKey.token);
  }

  // Function to delete an API key from secure storage
  @override
  Future<Either<RewildError, void>> deleteApiKey(String apiKeyType) async {
    try {
      await _secureStorage.delete(
          key: apiKeyType,
          aOptions: const AndroidOptions(encryptedSharedPreferences: true));
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: 'deleteApiKey',
        args: [apiKeyType],
      ));
    }
  }

  // Function to write data to secure storage
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
      ));
    }
  }

  // STATIC METHODS ========================================================== STATIC METHODS
  // Function to get API key in the background
  static Future<Either<RewildError, ApiKeyModel?>> getApiKeyInBackground(
      String type) async {
    final result = await _read(key: type);
    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return right(null);
      }
      return right(ApiKeyModel(token: r, type: type));
    });
  }

  // Function to get API key from secure storage in the background
  static Future<Either<RewildError, ApiKeyModel?>> getApiKeyFromBackground(
      String type) async {
    final result = await _read(key: type);

    return result.fold(
      (l) => left(l),
      (r) {
        if (r == null) {
          return right(null);
        }

        return right(ApiKeyModel(token: r, type: type));
      },
    );
  }

  // Function to read a value from secure storage
  static Future<Either<RewildError, String?>> _read(
      {required String key}) async {
    try {
      final value = await _secureStorage.read(
        key: key,
        aOptions: const AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

      return right(value);
    } catch (e) {
      return left(RewildError(
        "could not read from secure storage: $e",
        source: "SecureStorageDataProvider",
        name: '_read',
        args: [key],
      ));
    }
  }
}
