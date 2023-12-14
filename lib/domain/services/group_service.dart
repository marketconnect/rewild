import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/group_model.dart';

import 'package:rewild/presentation/add_group_screen/add_group_screen_view_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_view_model.dart';
import 'package:rewild/presentation/single_group_screen/single_groups_screen_view_model.dart';

abstract class GroupServiceGroupDataProvider {
  Future<Either<RewildError, GroupModel>> get(String name);
  Future<Either<RewildError, int>> insert(GroupModel group);
  Future<Either<RewildError, List<GroupModel>>> getAll([List<int>? nmIds]);
  Future<Either<RewildError, void>> delete(String name, [int? nmId]);
  Future<Either<RewildError, void>> renameGroup(
      String groupName, String newGroupName);
}

class GroupService
    implements
        AddGroupScreenGroupsService,
        AllCardsScreenGroupsService,
        AllGroupsScreenGroupsService,
        SingleGroupScreenGroupsService {
  final GroupServiceGroupDataProvider groupDataProvider;

  GroupService({required this.groupDataProvider});
  @override
  Future<Either<RewildError, void>> add(
      List<GroupModel> groups, List<int> productsCardsNmIds) async {
    for (final group in groups) {
      final response = await groupDataProvider.insert(GroupModel(
          name: group.name,
          bgColor: group.bgColor,
          fontColor: group.fontColor,
          cardsNmIds: productsCardsNmIds));
      if (response is Error) {
        return left(RewildError(response.message!,
            source: runtimeType.toString(), name: 'add', args: [group]);
      }
    }

    return right(null);
  }

  @override
  Future<Either<RewildError, List<GroupModel>>> getAll(
      [List<int>? nmIds]) async {
    final resource = await groupDataProvider.getAll(nmIds);

    if (resource is Empty) {
      return right([]);
    }
    return resource;
  }

  @override
  Future<Either<RewildError, GroupModel>> loadGroup(String name) async {
    return await groupDataProvider.get(name);
  }

  @override
  Future<Either<RewildError, void>> delete(String groupName, int nmId) {
    return groupDataProvider.delete(groupName, nmId);
  }

  @override
  Future<Either<RewildError, void>> deleteGroup(String groupName) {
    return groupDataProvider.delete(groupName);
  }

  @override
  Future<Either<RewildError, void>> renameGroup(
      String groupName, String newGroupName) {
    return groupDataProvider.renameGroup(groupName, newGroupName);
  }
}
