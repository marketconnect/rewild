import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/background_message.dart';
import 'package:rewild/domain/services/background_message_service.dart';

class BackgroundMessageDataProvider
    implements BackgroundMessageServiceBackgroundDataProvider {
  const BackgroundMessageDataProvider();

  @override
  Future<Resource<bool>> delete(BackgroundMessage message) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawDelete(
        'DELETE FROM background_messages WHERE id = ? AND subject = ? AND condition = ?',
        [message.id, message.subject, message.condition],
      );
      return Resource.success(id > 0);
    } catch (e) {
      return Resource.error("Ошибка удаления сообщения");
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
          id: maps[i]['id'],
          condition: maps[i]['condition'],
        );
      });
      return Resource.success(messages);
    } catch (e) {
      return Resource.error("Ошибка получения сообщения");
    }
  }

  static Future<Resource<bool>> saveInBackground(
      BackgroundMessage message) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert(
        'INSERT INTO background_messages (dateTime, subject, id, condition) VALUES (?, ?, ?, ?)',
        [
          // message.header,
          // message.message,
          message.dateTime.millisecondsSinceEpoch,
          message.subject,
          message.id,
          message.condition
        ],
      );
      return Resource.success(id > 0);
    } catch (e) {
      return Resource.error("Ошибка сохранения сообщения");
    }
  }
}
