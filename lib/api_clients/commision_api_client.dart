import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/commission_model.dart';
import 'package:rewild/domain/services/commission_service.dart';

import 'package:rewild/pb/message.pb.dart';
import 'package:rewild/pb/service.pbgrpc.dart';

class CommissionApiClient implements CommissionServiceCommissionApiClient {
  const CommissionApiClient();
  @override
  Future<Resource<CommissionModel>> get(int id) async {
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
      if (id == 0) {
        return Resource.error(
          "Некорректные данные",
        );
      }
      final stub = CommissionServiceClient(channel);
      final request = GetCommissionReq(
        id: Int64(id),
      );
      final response = await stub.getCommission(
        request,
      );

      final resultCommission = CommissionModel(
          id: id,
          category: response.category,
          subject: response.subject,
          commission: response.commission,
          fbs: response.fbs,
          fbo: response.fbo);

      return Resource.success(resultCommission);
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.internal) {
          return Resource.error(
            "Ошибка сервера",
          );
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(
            ErrorsConstants.unavailable,
          );
        }
      }
      return Resource.error(
        "Неизвестная ошибка во время получения данных об остатках с сервера: $e",
      );
    } finally {
      await channel.shutdown();
    }
  }
}
