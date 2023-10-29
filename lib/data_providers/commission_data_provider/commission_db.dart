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

  // final int id;
  // final String category;
  // final String subject;
  // final int commission;
  // final int fbs;
  // final int fbo;

  // CommissionDb(
  //     {required this.id,
  //     required this.category,
  //     required this.subject,
  //     required this.commission,
  //     required this.fbs,
  //     required this.fbo});

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
