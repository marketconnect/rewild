import 'package:grpc/grpc.dart';
import 'package:rewild/core/utils/api_helpers/api_helper.dart';

class CommissionApiHelper {
  static const String grpcHost = '89.108.70.221';

  static const int grpcPort = 25891;

  static ApiHelper get = ApiHelper(
    host: '',
    url: '',
    requestLimitPerMinute: 60,
    statusCodeDescriptions: {
      StatusCode.internal: 'Ошибка сервера',
      StatusCode.unavailable: 'Сервер временно недоступен, попробуйте позже',
    },
  );
}
