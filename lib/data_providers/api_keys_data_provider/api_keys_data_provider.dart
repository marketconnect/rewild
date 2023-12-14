// import 'package:rewild/core/utils/resource.dart';
// import 'package:rewild/core/utils/sqflite_service.dart';
// import 'package:rewild/domain/entities/api_key_model.dart';
// import 'package:rewild/domain/services/api_keys_service.dart';

// class ApiKeysDataProvider implements ApiKeysScreenApiKeysDataProvider {
//   ApiKeysDataProvider();

//   @override
//   Future<Either<RewildError,List<ApiKeyModel>>> getAllApiKeys() async {
//     try {
//       final db = await SqfliteService().database;
//       final apiKeys = await db.rawQuery(
//         'SELECT * FROM api_keys',
//       );
//       if (apiKeys.isEmpty) {
//         return right(null);
//       }
//       return right(
//         apiKeys.map((e) => ApiKeyModel.fromMap(e)).toList(),
//       );
//     } catch (e) {
//       return left(RewildError(
//         'Не удалось получить apiKeys из памяти телефона: ${e.toString()}',
//       );
//     }
//   }

//   @override
//   Future<Either<RewildError,void>> addApiKey(ApiKeyModel card) async {
//     try {
//       final db = await SqfliteService().database;
//       await db.insert(
//         'api_keys',
//         card.toMap(),
//       );
//       return right(null);
//     } catch (e) {
//       return left(RewildError(
//         'Не удалось обновить apiKeys в памяти телефона: ${e.toString()}',
//       );
//     }
//   }
// }
