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
  Future<Either<RewildError, String>> getUsername();
  Future<Either<RewildError, bool>> tokenNotExpiredInThreeMinutes();
}

abstract class AuthServiceAuthApiClient {
 Future<Either<RewildError, UserAuthData?>> registerUser(
      {required String username, required String password});
  Future<Either<RewildError, UserAuthData?>> loginUser(
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
    // get token
    final getTokenResult = await secureDataProvider.getToken();
    
    // check if token is not expired
    return getTokenResult.fold((l) => right(false), (r) async {
       final isTokenNotExpiredResult =
          await secureDataProvider.tokenNotExpiredInThreeMinutes();

      return isTokenNotExpiredResult.fold((l) => right(false), (r) async {
        return right(r);
      });
      
    });

    
  }

  @override
  Future<Either<RewildError, String>> getToken() async {
    final values = await Future.wait(
        [secureDataProvider.getUsername(), secureDataProvider.getToken()]);

    // Advert Info
    final userNameResult = values[0];
    final getTokenResult = values[1];
   
     // get user name
    return userNameResult.fold((l) => left(l), (userName) async {
     return getTokenResult.fold((l) => left(l), (token) async {
       
       if (token != null) { // token exists
      // check expiration
      final tokenNotExpiredResult =
          await secureDataProvider.tokenNotExpiredInThreeMinutes();

      return tokenNotExpiredResult.fold((l) => left(l), (tokenNotExpired) async {
        if (tokenNotExpired) { // token not expired
          return right(token);
        } else { // token expired
          // login
          final loginResult = await _login(userName);
        if (loginResult is Error) {
          return Resource.error(loginResult.message!,
              source: runtimeType.toString(), name: 'getToken', args: []);
        }

        // save received token
        final token = loginResult.data!.token;
        final expiredAt = loginResult.data!.expiredAt;
        final freebie = loginResult.data!.freebie;
        final saveResource = await _saveAuthData(
            UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
        if (saveResource is Error) {
          return Resource.error(saveResource.message!,
              source: runtimeType.toString(), name: 'getToken', args: []);
        }
        }
      });
      
      // If token not expired return token
      if (tokenNotExpired) {
        return getTokenResource;
      } else {
        // If token expired
        // login

        final loginResource = await _login(userName);
        if (loginResource is Error) {
          return Resource.error(loginResource.message!,
              source: runtimeType.toString(), name: 'getToken', args: []);
        }

        // save received token
        final token = loginResource.data!.token;
        final expiredAt = loginResource.data!.expiredAt;
        final freebie = loginResource.data!.freebie;
        final saveResource = await _saveAuthData(
            UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
        if (saveResource is Error) {
          return Resource.error(saveResource.message!,
              source: runtimeType.toString(), name: 'getToken', args: []);
        }

        return Resource.success(loginResource.data!.token);
      }

       } else {}
       

     });
    });
   

     
    

    

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
