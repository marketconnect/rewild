import 'package:rewild/domain/entities/pursued.dart';
import 'package:sqflite/sqflite.dart';

class PursuedDb extends PursuedModel {
  PursuedDb({required super.parentId, required super.property});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS pursued (
            parentId INTEGER,
            property TEXT
          )
          ''');
  }
}
