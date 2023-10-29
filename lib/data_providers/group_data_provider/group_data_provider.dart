import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/group_model.dart';
import 'package:rewild/domain/services/group_service.dart';

class GroupDataProvider implements GroupServiceGroupDataProvider {
  @override
  Future<Resource<int>> insert(GroupModel group) async {
    try {
      final db = await SqfliteService().database;
      for (final nmId in group.cardsNmIds) {
        await db.rawInsert(
          'INSERT INTO groups(name, bgColor, fontColor, nmId) VALUES(?,?,?,?)',
          [group.name, group.bgColor, group.fontColor, nmId],
        );
      }

      return Resource.success(group.cardsNmIds.length);
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  Future<Resource<void>> delete(int id, [int? nmId]) async {
    try {
      final db = await SqfliteService().database;
      if (nmId != null) {
        await db.rawDelete(
          'DELETE FROM groups WHERE nmId = ? AND id != ?',
          [nmId, id],
        );
      } else {
        await db.rawDelete('DELETE FROM groups WHERE id = ?', [id]);
      }
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<GroupModel>> get(int id) async {
    try {
      final db = await SqfliteService().database;
      final groups =
          await db.rawQuery('SELECT * FROM groups WHERE id = ?', [id]);

      String? name;
      int? bgColor;
      int? fontColor;
      List<int> nmIds = [];

      for (final group in groups) {
        if (name == null) {
          name = group['name'] as String;
          bgColor = group['bgColor'] as int;
          fontColor = group['fontColor'] as int;
        }
        final nmId = group['nmId'] as int;
        nmIds.add(nmId);
      }

      return Resource.success(GroupModel(
          name: name!,
          bgColor: bgColor!,
          fontColor: fontColor!,
          cardsNmIds: nmIds));
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  Future<Resource<int>> update(GroupModel group) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<List<GroupModel>>> getAll() async {
    try {
      List<GroupModel> resultGroups = [];
      final db = await SqfliteService().database;
      final groups = await db.rawQuery('SELECT * FROM groups');

      // get distinct groups names
      List<String> groupsNames = [];
      for (final group in groups) {
        final grName = group['name'] as String;
        groupsNames.add(grName);
      }

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

      return Resource.success(resultGroups);
    } catch (e) {
      return Resource.error(e.toString());
    }
  }
}
