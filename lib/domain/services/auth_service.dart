import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/user_auth_data.dart';

import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild/presentation/splash_screen/splash_screen_view_model.dart';

abstract class AuthServiceSecureDataProvider {
  Future<Either<RewildError, void>> updateUsername(
      {String? username, String? token, String? expiredAt, bool? freebie});
  Future<Either<RewildError, String?>> getToken();
  Future<Either<RewildError, String?>> getUsername();
  Future<Either<RewildError, bool>> tokenNotExpiredInThreeMinutes();
}

abstract class AuthServiceAuthApiClient {
  Future<Either<RewildError, UserAuthData>> registerUser(
      {required String username, required String password});
  Future<Either<RewildError, UserAuthData>> loginUser(
      {required String username, required String password});
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
    final getTokenEither = await secureDataProvider.getToken();
    if (getTokenEither.isLeft()) {
      return left(
          getTokenEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    // If token exist (registered)
    if (getTokenEither.isRight()) {
      // check expiration

      final tokenNotExpiredEither =
          await secureDataProvider.tokenNotExpiredInThreeMinutes();
      if (tokenNotExpiredEither.isLeft()) {
        return left(tokenNotExpiredEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
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
    final userNameEither = values[0];
    final getTokenEither = values[1];
    // get user name
    // final userNameResource = await secureDataProvider.getUsername();
    if (userNameEither.isLeft()) {
      return left(
          userNameEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final userName = userNameEither.fold((l) => null, (r) => r);
    if (userName == null) {
      return left(RewildError(
        'No username data',
        source: runtimeType.toString(),
        name: 'getToken',
      ));
    }

    // get token from secure storage
    // final getTokenResource = await secureDataProvider.getToken();
    if (getTokenEither.isLeft()) {
      return left(
          getTokenEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    // If token exist (registered)
    final token = getTokenEither.fold((l) => null, (r) => r);
    if (getTokenEither.isRight() && token != null) {
      // check expiration
      final tokenNotExpiredEither =
          await secureDataProvider.tokenNotExpiredInThreeMinutes();

      if (tokenNotExpiredEither.isLeft()) {
        return left(tokenNotExpiredEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      final tokenNotExpired = tokenNotExpiredEither.fold(
        (l) => false,
        (r) => r,
      );
      // If token not expired return token
      if (tokenNotExpired) {
        return right(token);
      } else {
        // If token expired
        // login

        final loginEither = await _login(userName);
        if (loginEither is Error) {
          return left(
              loginEither.fold((l) => l, (r) => throw UnimplementedError()));
        }

        // save received token
        final userAuthData =
            loginEither.fold((l) => throw UnimplementedError(), (r) => r);
        final token = userAuthData.token;
        final expiredAt = userAuthData.expiredAt;
        final freebie = userAuthData.freebie;
        final saveEither = await _saveAuthData(
            UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
        if (saveEither.isLeft()) {
          return left(
              saveEither.fold((l) => l, (r) => throw UnimplementedError()));
        }

        return right(token);
      }
    } else {
      // Token does not exist (not registered)
      // register
      final registerEither = await _register(userName);
      final userAuthData =
          registerEither.fold((l) => throw UnimplementedError(), (r) => r);
      if (registerEither is Error || userAuthData == null) {
        return left(
            registerEither.fold((l) => l, (r) => throw UnimplementedError()));
      }
      // save received data

      final token = userAuthData.token;
      final expiredAt = userAuthData.expiredAt;
      final freebie = userAuthData.freebie;
      final saveResource = await _saveAuthData(
          UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
      if (saveResource.isLeft()) {
        return left(
            saveResource.fold((l) => l, (r) => throw UnimplementedError()));
      }
      return right(token);
    }
  }

  Future<Either<RewildError, void>> _saveAuthData(UserAuthData authData) async {
    final token = authData.token;
    final freebie = authData.freebie;
    final expiredAt = authData.expiredAt;
    final saveEither = await secureDataProvider.updateUsername(
      token: token,
      expiredAt: expiredAt.toString(),
      freebie: freebie,
    );
    if (saveEither.isLeft()) {
      return left(saveEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    return right(null);
  }

  Future<Either<RewildError, UserAuthData?>> _register(String username) async {
    final authDataEither = await authApiClient.registerUser(
        username: username, password: username);
    if (authDataEither.isLeft()) {
      return left(
          authDataEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    return authDataEither;
  }

  Future<Either<RewildError, UserAuthData>> _login(String username) async {
    final authDataResource =
        await authApiClient.loginUser(password: username, username: username);
    if (authDataResource.isLeft()) {
      return left(
          authDataResource.fold((l) => l, (r) => throw UnimplementedError()));
    }

    return right(
        authDataResource.fold((l) => throw UnimplementedError(), (r) => r));
  }
}
