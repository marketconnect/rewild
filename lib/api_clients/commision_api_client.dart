import 'package:fixnum/fixnum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:grpc/grpc.dart';
import 'package:rewild/core/utils/api_helpers/commission_grpc_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/commission_model.dart';
import 'package:rewild/domain/services/commission_service.dart';

import 'package:rewild/pb/message.pb.dart';
import 'package:rewild/pb/service.pbgrpc.dart';

class CommissionApiClient implements CommissionServiceCommissionApiClient {
  const CommissionApiClient();
  @override
  Future<Either<RewildError, CommissionModel>> get(int id) async {
    final channel = ClientChannel(
      CommissionApiHelper.grpcHost,
      port: CommissionApiHelper.grpcPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: 5),
        connectionTimeout: Duration(seconds: 5),
      ),
    );
    try {
      if (id == 0) {
        return left(RewildError(
          "Некорректные данные",
          source: runtimeType.toString(),
          name: "get",
          args: [id],
        ));
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

      return right(resultCommission);
    } catch (e) {
      if (e is GrpcError) {
        final apiHelper = CommissionApiHelper.get;
        final errString = apiHelper.errResponse(
          statusCode: e.code,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "get",
          args: [id],
        ));
      }
      return left(RewildError(
        "Неизвестная ошибка",
        source: runtimeType.toString(),
        name: "get",
        args: [id],
      ));
    } finally {
      await channel.shutdown();
    }
  }
}
