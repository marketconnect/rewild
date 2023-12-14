// import 'package:rewild/core/utils/date_time_utils.dart';
// import 'package:rewild/core/utils/resource.dart';
// import 'package:rewild/domain/entities/price_history_model.dart';
// import 'package:rewild/presentation/single_seller_screen/single_seller_view_model.dart';

// abstract class PriceHistoryServicePriceHistoryApiClient {
//   Future<Either<RewildError,List<PriceHistoryModel>>> fetch(String link);
// }

// abstract class PriceHistoryServicePriceHistoryDataProvider {
//   Future<Either<RewildError,void>> insert(List<PriceHistoryModel> priceHistoryList);
//   Future<Either<RewildError,List<PriceHistoryModel>>> fetch(List<int> nmId);
//   Future<Either<RewildError,void>> delete(List<int> nmId);
// }

// class PriceHistoryService implements SingleSellerPriceHistoryService {
//   final PriceHistoryServicePriceHistoryDataProvider priceHistoryDataProvider;
//   final PriceHistoryServicePriceHistoryApiClient priceHistoryApiClient;
//   PriceHistoryService(
//       {required this.priceHistoryDataProvider,
//       required this.priceHistoryApiClient});

//   @override
//   Future<Either<RewildError,List<PriceHistoryModel>>> fetch(List<String> links) async {
//     Map<int, String> supplierIdMap = {};
//     for (final link in links) {
//       final nmId = int.tryParse(
//           link.split('/info/price-history.json')[0].split('/').last);
//       if (nmId == null) {
//         return left(RewildError(
//           "Некорректные данные: $nmId.",
//         );
//       }
//       supplierIdMap[nmId] = link;
//     }
//     List<PriceHistoryModel> priceHistoryResultList = [];
//     // get stored price history
//     final priceHistoryListResource =
//         await priceHistoryDataProvider.fetch(supplierIdMap.keys.toList());
//     if (priceHistoryListResource is Error) {
//       return left(RewildError(priceHistoryListResource.message!);
//     }
//     final priceHistoryList = priceHistoryListResource.data!;

//     // append absent and expired
//     // List<String> linkToUpdateList = [];
//     List<int> nmIdsToUpdate = [];
//     for (final priceHistory in priceHistoryList) {
//       if (isIntraday(
//           DateTime.fromMillisecondsSinceEpoch(priceHistory.updateAt))) {
//         priceHistoryResultList.add(priceHistory);
//         supplierIdMap.removeWhere((key, value) => key == priceHistory.nmId);
//       } else {
//         nmIdsToUpdate.add(priceHistory.nmId);
//       }
//     }
//     // delete expired
//     if (nmIdsToUpdate.isNotEmpty) {
//       final deleteResource =
//           await priceHistoryDataProvider.delete(nmIdsToUpdate);
//       if (deleteResource is Error) {
//         return left(RewildError(deleteResource.message!);
//       }
//     }
//     // merge absent and expired
//     List<String> linksToUpdateList = [];
//     for (final nmId in nmIdsToUpdate) {
//       linksToUpdateList.add(supplierIdMap[nmId]!);
//     }
//     linksToUpdateList.addAll(supplierIdMap.values.toList());
//     for (final link in linksToUpdateList) {
//       final insertResource = await priceHistoryApiClient.fetch(link);
//       if (insertResource is Error) {
//         return left(RewildError(insertResource.message!);
//       }
//       final insertList = insertResource.data!;
//       priceHistoryResultList.addAll(insertList);
//     }
//     final saveResource =
//         await priceHistoryDataProvider.insert(priceHistoryList);
//     if (saveResource is Error) {
//       return left(RewildError(saveResource.message!);
//     }
//     return right(priceHistoryResultList);
//   }
// }
