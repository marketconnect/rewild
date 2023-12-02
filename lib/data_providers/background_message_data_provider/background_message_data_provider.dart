import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/background_message.dart';
import 'package:rewild/domain/services/background_message_service.dart';

class BackgroundMessageDataProvider
    implements BackgroundMessageServiceBackgroundDataProvider {
  const BackgroundMessageDataProvider();

  @override
  Future<Resource<bool>> delete(int id, int subject, int condition) async {
    try {
      final db = await SqfliteService().database;
      final deletedID = await db.rawDelete(
        'DELETE FROM background_messages WHERE id = ? AND subject = ? AND condition = ?',
        [id, subject, condition],
      );
      return Resource.success(deletedID > 0);
    } catch (e) {
      return Resource.error("Ошибка удаления сообщения",
          source: runtimeType.toString(),
          name: "delete",
          args: [id, subject, condition]);
    }
  }

  @override
  Future<Resource<List<BackgroundMessage>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final List<Map<String, dynamic>> maps =
          await db.query('background_messages');
      final messages = List.generate(maps.length, (i) {
        return BackgroundMessage(
          // header: maps[i]['header'],
          // message: maps[i]['message'],
          dateTime: DateTime.fromMillisecondsSinceEpoch(maps[i]['dateTime']),
          subject: maps[i]['subject'],
          value: maps[i]['value'],
          id: maps[i]['id'],
          condition: maps[i]['condition'],
        );
      });
      return Resource.success(messages);
    } catch (e) {
      return Resource.error("Ошибка получения сообщения",
          source: runtimeType.toString(), name: "getAll", args: []);
    }
  }

  static Future<Resource<bool>> saveInBackground(
      BackgroundMessage message) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert(
        'INSERT INTO background_messages (dateTime, subject, id, condition, value) VALUES (?, ?, ?, ?, ?)',
        [
          message.dateTime.millisecondsSinceEpoch,
          message.subject,
          message.id,
          message.condition,
          message.value
        ],
      );
      return Resource.success(id > 0);
    } catch (e) {
      return Resource.error("Ошибка сохранения сообщения",
          source: "BackgroundMessageDataProvider",
          name: "saveInBackground",
          args: [message]);
    }
  }
}
