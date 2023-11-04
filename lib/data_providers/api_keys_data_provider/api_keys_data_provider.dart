// import 'package:rewild/core/utils/resource.dart';
// import 'package:rewild/core/utils/sqflite_service.dart';
// import 'package:rewild/domain/entities/api_key_model.dart';
// import 'package:rewild/domain/services/api_keys_service.dart';

// class ApiKeysDataProvider implements ApiKeysScreenApiKeysDataProvider {
//   ApiKeysDataProvider();

//   @override
//   Future<Resource<List<ApiKeyModel>>> getAllApiKeys() async {
//     try {
//       final db = await SqfliteService().database;
//       final apiKeys = await db.rawQuery(
//         'SELECT * FROM api_keys',
//       );
//       if (apiKeys.isEmpty) {
//         return Resource.empty();
//       }
//       return Resource.success(
//         apiKeys.map((e) => ApiKeyModel.fromMap(e)).toList(),
//       );
//     } catch (e) {
//       return Resource.error(
//         'Не удалось получить apiKeys из памяти телефона: ${e.toString()}',
//       );
//     }
//   }

//   @override
//   Future<Resource<void>> addApiKey(ApiKeyModel card) async {
//     try {
//       final db = await SqfliteService().database;
//       await db.insert(
//         'api_keys',
//         card.toMap(),
//       );
//       return Resource.empty();
//     } catch (e) {
//       return Resource.error(
//         'Не удалось обновить apiKeys в памяти телефона: ${e.toString()}',
//       );
//     }
//   }
// }
