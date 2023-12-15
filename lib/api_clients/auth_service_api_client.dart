import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/auth_grpc_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/user_auth_data.dart';
import 'package:rewild/domain/services/auth_service.dart';
import 'package:rewild/pb/message.pb.dart';
import 'package:rewild/pb/service.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class AuthApiClient implements AuthServiceAuthApiClient {
  const AuthApiClient();

  @override
  Future<Either<RewildError, UserAuthData?>> registerUser(
      {required String username, required String password}) async {
    final channel = ClientChannel(
      AuthApiHelper.grpcHost,
      port: AuthApiHelper.grpcPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: 5),
        connectionTimeout: Duration(seconds: 5),
      ),
    );
    try {
      final stub = AuthServiceClient(channel);

      final request = AuthRequest()
        ..username = username
        ..password = password;

      final response = await stub.register(request);
      final token = response.token;

      final expiredAt = response.expiredAt;

      return right(UserAuthData(
          token: token, expiredAt: expiredAt.toInt(), freebie: true));
    } catch (e) {
      if (e is GrpcError) {
        final apiHelper = AuthApiHelper.registerUser;
        final errString = apiHelper.errResponse(
          statusCode: e.code,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "registerUser",
          args: [username, password],
        ));
      }
      return left(RewildError(
        "Неизвестная ошибка",
        source: runtimeType.toString(),
        name: "registerUser",
        args: [username, password],
      ));
    } finally {
      await channel.shutdown();
    }
  }

  @override
  Future<Either<RewildError, UserAuthData?>> loginUser(
      {required String username, required String password}) async {
    final channel = ClientChannel(AuthApiHelper.grpcHost,
        port: AuthApiHelper.grpcPort,
        options: const ChannelOptions(
            credentials: ChannelCredentials.insecure(),
            connectTimeout: Duration(seconds: 5),
            connectionTimeout: Duration(seconds: 5)));

    try {
      final stub = AuthServiceClient(channel);

      final request = AuthRequest()
        ..username = username
        ..password = password;
      final response = await stub.login(request);
      final token = response.token;

      final expiredAt = response.expiredAt;
      return right(UserAuthData(
          token: token, expiredAt: expiredAt.toInt(), freebie: true));
    } catch (e) {
      if (e is GrpcError) {
        final apiHelper = AuthApiHelper.loginUser;
        final errString = apiHelper.errResponse(
          statusCode: e.code,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "loginUser",
          args: [username, password],
        ));
      }

      return left(RewildError(
        "Неизвестная ошибка",
        source: runtimeType.toString(),
        name: "loginUser",
        args: [username, password],
      ));
    } finally {
      await channel.shutdown();
    }
  }
}
