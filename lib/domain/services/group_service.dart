import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/group_model.dart';

import 'package:rewild/presentation/add_group_screen/add_group_screen_view_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_view_model.dart';
import 'package:rewild/presentation/single_group_screen/single_groups_screen_view_model.dart';

abstract class GroupServiceGroupDataProvider {
  Future<Resource<GroupModel>> get(String name);
  Future<Resource<int>> insert(GroupModel group);
  Future<Resource<List<GroupModel>>> getAll([List<int>? nmIds]);
  Future<Resource<void>> delete(String name, [int? nmId]);
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
  Future<Resource<void>> add(
      List<GroupModel> groups, List<int> productsCardsNmIds) async {
    for (final group in groups) {
      final response = await groupDataProvider.insert(GroupModel(
          name: group.name,
          bgColor: group.bgColor,
          fontColor: group.fontColor,
          cardsNmIds: productsCardsNmIds));
      if (response is Error) {
        return Resource.error(response.message!);
      }
    }

    return Resource.empty();
  }

  @override
  Future<Resource<List<GroupModel>>> getAll([List<int>? nmIds]) async {
    final resource = await groupDataProvider.getAll(nmIds);

    if (resource is Empty) {
      return Resource.success([]);
    }
    return resource;
  }

  @override
  Future<Resource<GroupModel>> loadGroup(String name) async {
    return await groupDataProvider.get(name);
  }

  @override
  Future<Resource<void>> delete(String groupName, int nmId) {
    return groupDataProvider.delete(groupName, nmId);
  }
}
