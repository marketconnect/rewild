import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/commission_model.dart';
import 'package:rewild/domain/services/commission_service.dart';

class CommissionDataProvider
    implements CommissionServiceCommissionDataProvider {
  const CommissionDataProvider();
  @override
  Future<Either<RewildError, CommissionModel?>> get({required int id}) async {
    try {
      final db = await SqfliteService().database;
      final commissions =
          await db.rawQuery('SELECT * FROM commissions WHERE id = ?', [id]);
      if (commissions.isEmpty) {
        return right(null);
      }

      return right(CommissionModel.fromMap(commissions.first));
    } catch (e) {
      return left(RewildError(
        'Ошибка во время получения комиссии ${e.toString()}',
        source: runtimeType.toString(),
        name: "get",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> insert(
      {required CommissionModel commission}) async {
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
      return right(null);
    } catch (e) {
      return left(RewildError(
        'Ошибка во время добавления комиссии ${e.toString()}',
        source: runtimeType.toString(),
        name: "insert",
        args: [commission],
      ));
    }
  }
}
