import 'package:sqflite/sqflite.dart';
import 'package:rewild/domain/entities/commission_model.dart';

class CommissionDb extends CommissionModel {
  CommissionDb(
      {required super.id,
      required super.category,
      required super.subject,
      required super.commission,
      required super.fbs,
      required super.fbo});

  static Future<void> createTable(Database db) async {
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS commissions (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        subject TEXT,
        commission INTEGER,
        fbs INTEGER,
        fbo INTEGER
      );
      ''',
    );
  }
}
