import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/user_auth_data.dart';

import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild/presentation/splash_screen/splash_screen_view_model.dart';

abstract class AuthServiceSecureDataProvider {
  Future<Either<RewildError, void>> updateUsername(
      {String? username, String? token, String? expiredAt, bool? freebie});
  Future<Either<RewildError, String>> getToken();
  Future<Either<RewildError, String>> getUsername();
  Future<Either<RewildError, bool>> tokenNotExpiredInThreeMinutes();
}

abstract class AuthServiceAuthApiClient {
  Future<Either<RewildError, UserAuthData?>> registerUser(
      String username, String password);
  Future<Either<RewildError, UserAuthData?>> loginUser(
      String username, String password);
}

class AuthServiceImpl
    implements
        SplashScreenViewModelAuthService,
        AllCardsScreenTokenProvider,
        MyWebViewScreenViewModelTokenProvider {
  final AuthServiceSecureDataProvider secureDataProvider;
  final AuthServiceAuthApiClient authApiClient;

  const AuthServiceImpl(
      {required this.secureDataProvider, required this.authApiClient});

  @override
  Future<Either<RewildError, bool>> isLogined() async {
    // get token
    final getTokenResource = await secureDataProvider.getToken();
    if (getTokenResource is Error) {
      return left(RewildError(getTokenResource.message!,
          source: runtimeType.toString(), name: 'isLogined', args: []);
    }
    // If token exist (registered)
    if (getTokenResource is Success) {
      // check expiration

      final tokenNotExpiredResource =
          await secureDataProvider.tokenNotExpiredInThreeMinutes();
      if (tokenNotExpiredResource is Error) {
        return left(RewildError(tokenNotExpiredResource.message!,
            source: runtimeType.toString(), name: 'isLogined', args: []);
      }
      return right(true);
    }
    return right(false);
  }

  @override
  Future<Either<RewildError, String>> getToken() async {
    final values = await Future.wait(
        [secureDataProvider.getUsername(), secureDataProvider.getToken()]);

    // Advert Info
    final userNameResource = values[0];
    final getTokenResource = values[1];
    // get user name
    // final userNameResource = await secureDataProvider.getUsername();
    if (userNameResource is Error) {
      return left(RewildError(userNameResource.message!,
          source: runtimeType.toString(), name: 'getToken', args: []);
    }
    final userName = userNameResource.data!;

    // get token from secure storage
    // final getTokenResource = await secureDataProvider.getToken();
    if (getTokenResource is Error) {
      return left(RewildError(getTokenResource.message!,
          source: runtimeType.toString(), name: 'getToken', args: []);
    }
    // If token exist (registered)
    if (getTokenResource is Success) {
      // check expiration
      final tokenNotExpiredResource =
          await secureDataProvider.tokenNotExpiredInThreeMinutes();

      if (tokenNotExpiredResource is Error) {
        return left(RewildError(tokenNotExpiredResource.message!,
            source: runtimeType.toString(), name: 'getToken', args: []);
      }
      final tokenNotExpired = tokenNotExpiredResource.data!;
      // If token not expired return token
      if (tokenNotExpired) {
        return getTokenResource;
      } else {
        // If token expired
        // login

        final loginResource = await _login(userName);
        if (loginResource is Error) {
          return left(RewildError(loginResource.message!,
              source: runtimeType.toString(), name: 'getToken', args: []);
        }

        // save received token
        final token = loginResource.data!.token;
        final expiredAt = loginResource.data!.expiredAt;
        final freebie = loginResource.data!.freebie;
        final saveResource = await _saveAuthData(
            UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
        if (saveResource is Error) {
          return left(RewildError(saveResource.message!,
              source: runtimeType.toString(), name: 'getToken', args: []);
        }

        return right(loginResource.data!.token);
      }
    } else {
      // Token does not exist (not registered)
      // register
      final registerResource = await _register(userName);
      if (registerResource is Error) {
        return left(RewildError(registerResource.message!,
            source: runtimeType.toString(), name: 'getToken', args: []);
      }
      // save received data
      final token = registerResource.data!.token;
      final expiredAt = registerResource.data!.expiredAt;
      final freebie = registerResource.data!.freebie;
      final saveResource = await _saveAuthData(
          UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
      if (saveResource is Error) {
        return left(RewildError(saveResource.message!,
            source: runtimeType.toString(), name: 'getToken', args: []);
      }
      return right(registerResource.data!.token);
    }
  }

  Future<Either<RewildError, void>> _saveAuthData(UserAuthData authData) async {
    final token = authData.token;
    final freebie = authData.freebie;
    final expiredAt = authData.expiredAt;
    final saveResource = await secureDataProvider.updateUsername(
      token: token,
      expiredAt: expiredAt.toString(),
      freebie: freebie,
    );
    if (saveResource is Error) {
      return left(RewildError(saveResource.message!,
          source: runtimeType.toString(),
          name: '_saveAuthData',
          args: [authData]);
    }
    return right(null);
  }

  Future<Either<RewildError, UserAuthData>> _register(String username) async {
    final authDataResource =
        await authApiClient.registerUser(username, username);
    if (authDataResource is Error) {
      return left(RewildError(authDataResource.message!,
          source: runtimeType.toString(), name: '_register', args: [username]);
    }
    return Success(data: authDataResource.data!);
  }

  Future<Either<RewildError, UserAuthData>> _login(String username) async {
    final authDataResource = await authApiClient.loginUser(username, username);
    if (authDataResource is Error) {
      return left(RewildError(authDataResource.message!,
          source: runtimeType.toString(), name: '_login', args: [username]);
    }

    return Success(data: authDataResource.data!);
  }
}
