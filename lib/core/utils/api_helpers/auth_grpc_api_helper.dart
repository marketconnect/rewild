import 'package:grpc/grpc.dart';
import 'package:rewild/core/utils/api_helpers/api_helper.dart';

class AuthApiHelper {
  static const String grpcHost = '89.108.70.221';

  static const int grpcPort = 25891;

  static ApiHelper loginUser = ApiHelper(
    host: '',
    url: '',
    requestLimitPerMinute: 60,
    statusCodeDescriptions: {
      StatusCode.notFound: 'Пользователь не найден',
      StatusCode.internal: 'Ошибка сервера',
      StatusCode.unavailable: 'Сервер временно недоступен, попробуйте позже',
    },
  );

  static ApiHelper registerUser = ApiHelper(
    host: '',
    url: '',
    requestLimitPerMinute: 0,
    statusCodeDescriptions: {
      StatusCode.alreadyExists: "ALREADY_EXISTS",
      StatusCode.invalidArgument: "Некорректные данные",
      StatusCode.internal: "Ошибка сервера",
      StatusCode.unavailable: "Сервер временно недоступен, попробуйте позже.",
    },
  );
}
