import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/services/update_service.dart';
import 'package:rewild/pb/message.pb.dart';
import 'package:rewild/pb/service.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

class InitialStocksApiClient implements UpdateServiceInitialStockApiClient {
  const InitialStocksApiClient();
  @override
  Future<Resource<List<InitialStockModel>>> get(
      List<int> skus, DateTime dateFrom, DateTime dateTo) async {
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
      final dateToSave = dateFrom.add(const Duration(seconds: 6));
      if (skus.isEmpty) {
        return Resource.error(
          "Некорректные данные",
          source: runtimeType.toString(),
          name: "get",
          args: [skus, dateFrom, dateTo],
        );
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

      return Resource.success(initialStocks);
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.internal) {
          return Resource.error(
            "Ошибка сервера",
            source: runtimeType.toString(),
            name: "get",
            args: [skus, dateFrom, dateTo],
          );
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(
            ErrorsConstants.unavailable,
            source: runtimeType.toString(),
            name: "get",
            args: [skus, dateFrom, dateTo],
          );
        }
      }
      return Resource.error(
        "Неизвестная ошибка во время получения данных об остатках с сервера: $e",
        source: runtimeType.toString(),
        name: "get",
        args: [skus, dateFrom, dateTo],
      );
    } finally {
      await channel.shutdown();
    }
  }

  static Future<Resource<List<InitialStockModel>>> getInBackground(
      List<int> skus, DateTime dateFrom, DateTime dateTo) async {
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
      final dateToSave = dateFrom.add(const Duration(seconds: 6));
      if (skus.isEmpty) {
        return Resource.error(
          "Некорректные данные",
          source: "InitialStocksApiClient",
          name: "getInBackground",
          args: [skus, dateFrom, dateTo],
        );
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

      return Resource.success(initialStocks);
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.internal) {
          return Resource.error(
            "Ошибка сервера",
            source: "InitialStocksApiClient",
            name: "getInBackground",
            args: [skus, dateFrom, dateTo],
          );
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(
            ErrorsConstants.unavailable,
            source: "InitialStocksApiClient",
            name: "getInBackground",
            args: [skus, dateFrom, dateTo],
          );
        }
      }
      return Resource.error(
        "Неизвестная ошибка во время получения данных об остатках с сервера: $e",
        source: "InitialStocksApiClient",
        name: "getInBackground",
        args: [skus, dateFrom, dateTo],
      );
    } finally {
      await channel.shutdown();
    }
  }
}
