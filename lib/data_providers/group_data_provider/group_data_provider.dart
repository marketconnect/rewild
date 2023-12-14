import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/group_model.dart';
import 'package:rewild/domain/services/group_service.dart';

class GroupDataProvider implements GroupServiceGroupDataProvider {
  const GroupDataProvider();
  @override
  Future<Either<RewildError, int>> insert(GroupModel group) async {
    try {
      final db = await SqfliteService().database;
      for (final nmId in group.cardsNmIds) {
        await db.rawInsert(
          'INSERT INTO groups(name, bgColor, fontColor, nmId) VALUES(?,?,?,?)',
          [group.name, group.bgColor, group.fontColor, nmId],
        );
      }

      return right(group.cardsNmIds.length);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "insert", args: [group]));
    }
  }

  @override
  Future<Either<RewildError, void>> renameGroup(
      String groupName, String newGroupName) async {
    try {
      final db = await SqfliteService().database;
      await db.rawUpdate(
        'UPDATE groups SET name = ? WHERE name = ?',
        [newGroupName, groupName],
      );
      return right(null);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(),
          name: "renameGroup",
          args: [groupName, newGroupName]));
    }
  }

  @override
  Future<Either<RewildError, void>> delete(String name, [int? nmId]) async {
    try {
      final db = await SqfliteService().database;
      if (nmId != null) {
        await db.rawDelete(
          'DELETE FROM groups WHERE nmId = ? AND name = ?',
          [nmId, name],
        );
      } else {
        await db.rawDelete('DELETE FROM groups WHERE name = ?', [name]);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "delete", args: [name, nmId]));
    }
  }

  @override
  Future<Either<RewildError, GroupModel?>> get(String name) async {
    try {
      final db = await SqfliteService().database;
      final groups =
          await db.rawQuery('SELECT * FROM groups WHERE name = ?', [name]);

      if (groups.isEmpty) {
        return right(null);
      }

      int? bgColor;
      int? fontColor;
      List<int> nmIds = [];

      for (final group in groups) {
        if (bgColor == null) {
          bgColor = group['bgColor'] as int;
          fontColor = group['fontColor'] as int;
        }
        final nmId = group['nmId'] as int;
        nmIds.add(nmId);
      }

      return right(GroupModel(
          name: name,
          bgColor: bgColor!,
          fontColor: fontColor!,
          cardsNmIds: nmIds));
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "get", args: [name]));
    }
  }

  Future<Either<RewildError, int>> update(GroupModel group) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawUpdate(
        '''
  UPDATE groups
  SET
    name = ?,
    bgColor = ?,
    fontColor = ?
  WHERE
    id = ?
  ''',
        [
          group.name,
          group.bgColor,
          group.fontColor,
          group.id,
        ],
      );
      return right(id);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "update", args: [group]));
    }
  }

  @override
  Future<Either<RewildError, List<GroupModel>?>> getAll(
      [List<int>? nmIds]) async {
    try {
      List<GroupModel> resultGroups = [];
      List<Map<String, Object?>> groups;
      final db = await SqfliteService().database;
      if (nmIds != null) {
        groups = await db.rawQuery(
          'SELECT * FROM groups WHERE nmId IN (${nmIds.map((e) => '?').join(',')})',
        );
      } else {
        groups = await db.rawQuery('SELECT * FROM groups');
      }
      // final

      if (groups.isEmpty) {
        return right(null);
      }
      // get distinct groups names
      List<String> groupsNames = [];
      for (final group in groups) {
        final grName = group['name'] as String;
        groupsNames.add(grName);
      }
      groupsNames = groupsNames.toSet().toList();
      // add groups to the list
      for (final grName in groupsNames) {
        final groupMapsList = groups.where((e) => e['name'] == grName).toList();

        String? name;
        int? bgColor;
        int? fontColor;
        List<int> nmIds = [];
        for (final group in groupMapsList) {
          if (name == null) {
            name = group['name'] as String;
            bgColor = group['bgColor'] as int;
            fontColor = group['fontColor'] as int;
          }
          final nmId = group['nmId'] as int;
          nmIds.add(nmId);
        }

        resultGroups.add(GroupModel(
            name: name!,
            bgColor: bgColor!,
            fontColor: fontColor!,
            cardsNmIds: nmIds));
      }

      return right(resultGroups);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "getAll", args: [nmIds]));
    }
  }
}
