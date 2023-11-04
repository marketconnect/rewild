// import 'package:rewild/core/utils/resource.dart';
// import 'package:rewild/core/utils/sqflite_service.dart';
// import 'package:rewild/domain/entities/price_history_model.dart';
// import 'package:rewild/domain/services/price_history_service.dart';

// class PriceHistoryDataProvider
//     implements PriceHistoryServicePriceHistoryDataProvider {
//   const PriceHistoryDataProvider();
//   @override
//   Future<Resource<void>> insert(
//       List<PriceHistoryModel> priceHistoryList) async {
//     try {
//       final db = await SqfliteService().database;
//       for (final priceHistory in priceHistoryList) {
//         await db.rawInsert(
//             'INSERT INTO price_history(nmId, dt, price, updateAt) VALUES(?,?,?,?)',
//             [
//               priceHistory.nmId,
//               priceHistory.dt,
//               priceHistory.price,
//               priceHistory.updateAt
//             ]);
//       }
//       return Resource.empty();
//     } catch (e) {
//       return Resource.error(
//           'Не удалось обновить историю изменения цены: ${e.toString()}');
//     }
//   }

//   @override
//   Future<Resource<List<PriceHistoryModel>>> fetch(List<int> nmId) async {
//     try {
//       final db = await SqfliteService().database;
//       final priceHistoryList = await db.rawQuery(
//           'SELECT * FROM price_history WHERE nmId IN (${nmId.join(',')})');
//       return Resource.success(
//         priceHistoryList.map((e) => PriceHistoryModel.fromMap(e)).toList(),
//       );
//     } catch (e) {
//       return Resource.error(
//         'Не удалось получить историю изменения цены: ${e.toString()}',
//       );
//     }
//   }

//   @override
//   Future<Resource<void>> delete(List<int> nmId) async {
//     try {
//       final db = await SqfliteService().database;
//       for (final nmId in nmId) {
//         await db.rawDelete('DELETE FROM price_history WHERE nmId = ?', [nmId]);
//       }
//       return Resource.empty();
//     } catch (e) {
//       return Resource.error(
//         'Не удалось удалить историю изменения цены: ${e.toString()}',
//       );
//     }
//   }
// }
