import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/initial_stocks_grpc_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/services/update_service.dart';
import 'package:rewild/pb/message.pb.dart';
import 'package:rewild/pb/service.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

class InitialStocksApiClient implements UpdateServiceInitialStockApiClient {
  const InitialStocksApiClient();
  @override
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required List<int> skus,
      required DateTime dateFrom,
      required DateTime dateTo}) async {
    final channel = ClientChannel(
      InitialStocksApiHelper.grpcHost,
      port: InitialStocksApiHelper.grpcPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: 5),
        connectionTimeout: Duration(seconds: 5),
      ),
    );
    try {
      final dateToSave = dateFrom.add(const Duration(seconds: 6));
      if (skus.isEmpty) {
        return left(RewildError(
          "Некорректные данные",
          source: runtimeType.toString(),
          name: "get",
          args: [skus, dateFrom, dateTo],
        ));
      }
      final stub = StockServiceClient(channel);
      final request = GetStocksFromToReq(
        skus: skus.map((e) => Int64(e)).toList(),
        from: Int64(dateFrom.millisecondsSinceEpoch),
        to: Int64(dateTo.millisecondsSinceEpoch),
      );
      final response = await stub.getStocksFromTo(
        request,
      );

      List<InitialStockModel> initialStocks = [];
      final initialStocksFromServer = response.stocks;

      for (final stock in initialStocksFromServer) {
        initialStocks.add(InitialStockModel(
          nmId: stock.sku.toInt(),
          wh: stock.wh.toInt(),
          sizeOptionId: stock.sizeOptionId.toInt(),
          date: dateToSave,
          qty: stock.qty.toInt(),
        ));
      }

      return right(initialStocks);
    } catch (e) {
      if (e is GrpcError) {
        final apiHelper = InitialStocksApiHelper.get;
        final errString = apiHelper.errResponse(
          statusCode: e.code,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "get",
          args: [skus, dateFrom, dateTo],
        ));
      }
      return left(RewildError(
        "Неизвестная ошибка",
        source: runtimeType.toString(),
        name: "get",
        args: [skus, dateFrom, dateTo],
      ));
    } finally {
      await channel.shutdown();
    }
  }

  static Future<Either<RewildError, List<InitialStockModel>>> getInBackground(
      {required List<int> skus,
      required DateTime dateFrom,
      required DateTime dateTo}) async {
    final channel = ClientChannel(
      InitialStocksApiHelper.grpcHost,
      port: InitialStocksApiHelper.grpcPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: 5),
        connectionTimeout: Duration(seconds: 5),
      ),
    );
    try {
      final dateToSave = dateFrom.add(const Duration(seconds: 6));
      if (skus.isEmpty) {
        return left(RewildError(
          "Некорректные данные",
          source: "InitialStocksApiClient",
          name: "getInBackground",
          args: [skus, dateFrom, dateTo],
        ));
      }
      final stub = StockServiceClient(channel);
      final request = GetStocksFromToReq(
        skus: skus.map((e) => Int64(e)).toList(),
        from: Int64(dateFrom.millisecondsSinceEpoch),
        to: Int64(dateTo.millisecondsSinceEpoch),
      );
      final response = await stub.getStocksFromTo(
        request,
      );

      List<InitialStockModel> initialStocks = [];
      final initialStocksFromServer = response.stocks;

      for (final stock in initialStocksFromServer) {
        initialStocks.add(InitialStockModel(
          nmId: stock.sku.toInt(),
          wh: stock.wh.toInt(),
          sizeOptionId: stock.sizeOptionId.toInt(),
          date: dateToSave,
          qty: stock.qty.toInt(),
        ));
      }

      return right(initialStocks);
    } catch (e) {
      if (e is GrpcError) {
        final apiHelper = InitialStocksApiHelper.get;
        final errString = apiHelper.errResponse(
          statusCode: e.code,
        );
        return left(RewildError(
          errString,
          source: "InitialStocksApiClient",
          name: "get",
          args: [skus, dateFrom, dateTo],
        ));
      }
      return left(RewildError(
        "Неизвестная ошибка",
        source: "InitialStocksApiClient",
        name: "get",
        args: [skus, dateFrom, dateTo],
      ));
    } finally {
      await channel.shutdown();
    }
  }
}
