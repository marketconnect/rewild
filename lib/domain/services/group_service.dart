import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/group_model.dart';

import 'package:rewild/presentation/add_group/add_group_screen_view_model.dart';
import 'package:rewild/presentation/all_cards/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/all_groups/all_groups_view_model.dart';
import 'package:rewild/presentation/single_group/single_groups_screen_view_model.dart';

abstract class GroupServiceGroupDataProvider {
  Future<Resource<GroupModel>> get(int id);
  Future<Resource<int>> insert(GroupModel group);
  Future<Resource<List<GroupModel>>> getAll();
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
  Future<Resource<List<GroupModel>>> getAll() async {
    final resource = await groupDataProvider.getAll();
    if (resource is Error) {
      return Resource.error(resource.message!);
    }
    return Resource.success(resource.data!);
  }

  @override
  Future<Resource<GroupModel>> loadGroup(int id) async {
    final resource = await groupDataProvider.get(id);
    if (resource is Error) {
      return Resource.error(resource.message!);
    }
    return Resource.success(resource.data!);
  }
}
