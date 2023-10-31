import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/user_auth_data.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild/presentation/splash_screen/splash_screen_view_model.dart';

abstract class AuthServiceSecureDataProvider {
  Future<Resource<void>> update(
      {String? username, String? token, String? expiredAt, bool? freebie});
  Future<Resource<String>> getToken();
  Future<Resource<String>> getUsername();
  Future<Resource<bool>> tokenNotExpiredInThreeMinutes();
}

abstract class AuthServiceAuthApiClient {
  Future<Resource<UserAuthData?>> registerUser(
      String username, String password);
  Future<Resource<UserAuthData?>> loginUser(String username, String password);
}

class AuthServiceImpl
    implements
        SplashScreenViewModelAuthService,
        AllCardsScreenTokenProvider,
        MyWebViewScreenViewModelTokenProvider {
  final AuthServiceSecureDataProvider secureDataProvider;
  final AuthServiceAuthApiClient authApiClient;

  AuthServiceImpl(
      {required this.secureDataProvider, required this.authApiClient});

  @override
  Future<Resource<bool>> isLogined() async {
    // get token
    final getTokenResource = await secureDataProvider.getToken();
    if (getTokenResource is Error) {
      return Resource.error(
        getTokenResource.message!,
      );
    }
    // If token exist (registered)
    if (getTokenResource is Success) {
      // check expiration

      final tokenNotExpiredResource =
          await secureDataProvider.tokenNotExpiredInThreeMinutes();
      if (tokenNotExpiredResource is Error) {
        return Resource.error(
          tokenNotExpiredResource.message!,
        );
      }
      return Resource.success(true);
    }
    return Resource.success(false);
  }

  @override
  Future<Resource<String>> getToken() async {
    // get user name
    final userNameResource = await secureDataProvider.getUsername();
    if (userNameResource is Error) {
      return Resource.error(
        userNameResource.message!,
      );
    }
    final userName = userNameResource.data!;

    // get token from secure storage
    final getTokenResource = await secureDataProvider.getToken();
    if (getTokenResource is Error) {
      return Resource.error(
        getTokenResource.message!,
      );
    }
    // If token exist (registered)
    if (getTokenResource is Success) {
      // check expiration
      final tokenNotExpiredResource =
          await secureDataProvider.tokenNotExpiredInThreeMinutes();

      if (tokenNotExpiredResource is Error) {
        return Resource.error(
          tokenNotExpiredResource.message!,
        );
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
          return Resource.error(
            loginResource.message!,
          );
        }

        // save received token
        final token = loginResource.data!.token;
        final expiredAt = loginResource.data!.expiredAt;
        final freebie = loginResource.data!.freebie;
        final saveResource = await _saveAuthData(
            UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
        if (saveResource is Error) {
          return Resource.error(saveResource.message!);
        }

        return Resource.success(loginResource.data!.token);
      }
    } else {
      // Token does not exist (not registered)
      // register
      final registerResource = await _register(userName);
      if (registerResource is Error) {
        return Resource.error(
          registerResource.message!,
        );
      }
      // save received data
      final token = registerResource.data!.token;
      final expiredAt = registerResource.data!.expiredAt;
      final freebie = registerResource.data!.freebie;
      final saveResource = await _saveAuthData(
          UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
      if (saveResource is Error) {
        return Resource.error(saveResource.message!);
      }
      return Resource.success(registerResource.data!.token);
    }
  }

  Future<Resource<void>> _saveAuthData(UserAuthData authData) async {
    final token = authData.token;
    final freebie = authData.freebie;
    final expiredAt = authData.expiredAt;
    final saveResource = await secureDataProvider.update(
      token: token,
      expiredAt: expiredAt.toString(),
      freebie: freebie,
    );
    if (saveResource is Error) {
      return Resource.error(
        saveResource.message!,
      );
    }
    return Resource.empty();
  }

  Future<Resource<UserAuthData>> _register(String username) async {
    final authDataResource =
        await authApiClient.registerUser(username, username);
    if (authDataResource is Error) {
      return Resource.error(
        authDataResource.message!,
      );
    }
    return Success(data: authDataResource.data!);
  }

  Future<Resource<UserAuthData>> _login(String username) async {
    final authDataResource = await authApiClient.loginUser(username, username);
    if (authDataResource is Error) {
      return Resource.error(
        authDataResource.message!,
      );
    }

    return Success(data: authDataResource.data!);
  }
}
