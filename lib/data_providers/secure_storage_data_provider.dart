import 'dart:math';
import 'package:android_id/android_id.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/services/auth_service.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageProviderImpl implements AuthServiceSecureDataProvider {
  static const _secureStorage = FlutterSecureStorage();

  @override
  Future<Resource<void>> update(
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
      );
    }
    String? expiredAt = resource.data;
    if (expiredAt == null) {
      return Resource.error('No token expiration data');
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

        await update(username: deviceId);
      } on Exception catch (e) {
        return Resource.error(
          e.toString(),
        );
      }
    }
    return Resource.success(deviceId);
  }

  Future<Resource<String?>> _read({required String key}) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) {
        return Resource.empty();
      }
      return Resource.success(value);
    } catch (e) {
      return Resource.error(
        "could not read from secure storage: $e",
      );
    }
  }

  Future<Resource<void>> _write(
      {required String key, required String? value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "could not write to secure storage: $e",
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
}
