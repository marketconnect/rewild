import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/commission_model.dart';
import 'package:rewild/domain/services/commission_service.dart';

class CommissionDataProvider
    implements CommissionServiceCommissionDataProvider {
  @override
  Future<Resource<CommissionModel>> get(int id) async {
    try {
      final db = await SqfliteService().database;
      final commissions =
          await db.rawQuery('SELECT * FROM commissions WHERE id = ?', [id]);
      if (commissions.isEmpty) {
        return Resource.empty();
      }

      return Resource.success(CommissionModel.fromMap(commissions.first));
    } catch (e) {
      return Resource.error(
          'Ошибка во время получения комиссии ${e.toString()}');
    }
  }

  @override
  Future<Resource<void>> insert(CommissionModel commission) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawInsert('''
      INSERT INTO commissions (
        id,
        category,
        subject,
        commission,
        fbs,
        fbo
      ) VALUES(
        ?,?,?,?, ?, ?
      )''', [
        commission.id,
        commission.category,
        commission.subject,
        commission.commission,
        commission.fbs,
        commission.fbo
      ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(
          'Ошибка во время добавления комиссии ${e.toString()}');
    }
  }
}
