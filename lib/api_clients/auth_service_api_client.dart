import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/user_auth_data.dart';
import 'package:rewild/domain/services/auth_service.dart';
import 'package:rewild/pb/message.pb.dart';
import 'package:rewild/pb/service.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class AuthApiClient implements AuthServiceAuthApiClient {
  const AuthApiClient();

  @override
  Future<Resource<UserAuthData?>> registerUser(
      String username, String password) async {
    final channel = ClientChannel(
      APIConstants.apiHost,
      port: APIConstants.apiPort,
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

      return Resource.success(UserAuthData(
          token: token, expiredAt: expiredAt.toInt(), freebie: true));
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.alreadyExists) {
          return Resource.error(
            "ALREADY_EXISTS",
            source: runtimeType.toString(),
            name: "registerUser",
            args: [username, password],
          );
        } else if (e.code == StatusCode.invalidArgument) {
          return Resource.error(
            "Некорректные данные",
            source: runtimeType.toString(),
            name: "registerUser",
            args: [username, password],
          );
        } else if (e.code == StatusCode.internal) {
          return Resource.error(
            "Ошибка сервера",
            source: runtimeType.toString(),
            name: "registerUser",
            args: [username, password],
          );
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(
            ErrorsConstants.unavailable,
            source: runtimeType.toString(),
            name: "registerUser",
            args: [username, password],
          );
        } else {
          return Resource.error(
            "Неизвестная ошибка",
            source: runtimeType.toString(),
            name: "registerUser",
            args: [username, password],
          );
        }
      }
    } finally {
      await channel.shutdown();
    }

    return Resource.error(
      "Неизвестная ошибка",
      source: runtimeType.toString(),
      name: "registerUser",
      args: [username, password],
    );
  }

  @override
  Future<Resource<UserAuthData?>> loginUser(
      String username, String password) async {
    final channel = ClientChannel(APIConstants.apiHost,
        port: APIConstants.apiPort,
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

      return Resource.success(UserAuthData(
          token: token, expiredAt: expiredAt.toInt(), freebie: true));
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.notFound) {
          return Resource.error("Пользователь не найден",
              source: runtimeType.toString(),
              name: "loginUser",
              args: [username, password]);
        } else if (e.code == StatusCode.internal) {
          return Resource.error("Ошибка сервера",
              source: runtimeType.toString(),
              name: "loginUser",
              args: [username, password]);
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(ErrorsConstants.unavailable,
              source: runtimeType.toString(),
              name: "loginUser",
              args: [username, password]);
        } else {}
      }
    } finally {
      await channel.shutdown();
    }

    return Resource.error("Неизвестная ошибка",
        source: runtimeType.toString(),
        name: "loginUser",
        args: [username, password]);
  }
}
