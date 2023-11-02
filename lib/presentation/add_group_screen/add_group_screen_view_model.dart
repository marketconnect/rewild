import 'package:rewild/core/color.dart';
import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/entities/group_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';

abstract class AddGroupScreenGroupsService {
  Future<Resource<List<GroupModel>>> getAll();
  Future<Resource<void>> add(
      List<GroupModel> groups, List<int> productsCardsNmIds);
}

class AddGroupScreenViewModel extends ChangeNotifier {
  final AddGroupScreenGroupsService groupsProvider;

  final BuildContext context;

  final List<int> productsCardsIds;
  AddGroupScreenViewModel(
      {required this.context,
      required this.groupsProvider,
      required this.productsCardsIds}) {
    asyncInit();
  }

  Future<void> asyncInit() async {
    final groupsResource = await groupsProvider.getAll();
    if (groupsResource is Error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(groupsResource.message!),
      ));
      return;
    }

    _groups = groupsResource.data!;
    notifyListeners();
  }

  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;

  void addGroup(String newGroupName) async {
    if (newGroupName == "") {
      return;
    }
    debugPrint(newGroupName);
    newGroupName = newGroupName.trim();
    final generatedColors = ColorsConstants.getColorsPair(groups.length);
    GroupModel newGroup = GroupModel(
        name: newGroupName,
        bgColor: generatedColors.backgroundColor.value,
        cardsNmIds: [],
        fontColor: generatedColors.fontColor.value);
    if (groups.where((element) => element.name == newGroup.name).isNotEmpty) {
      return;
    }
    groups.add(newGroup);
    // await groupsProvider.addGroup(newGroup);
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.of(context).pop();
    notifyListeners();
  }

  final List<String> _selectedGroupsNames = [];
  List<String> get selectedGroupsNames => _selectedGroupsNames;

  void selectGroup(String name) {
    _selectedGroupsNames.contains(name)
        ? _selectedGroupsNames.remove(name)
        : _selectedGroupsNames.add(name);
    notifyListeners();
  }

  void save() async {
    if (selectedGroupsNames.isNotEmpty) {
      final groupsToAdd = _groups.where((element) {
        return selectedGroupsNames.contains(element.name);
      }).toList();
      await groupsProvider.add(groupsToAdd, productsCardsIds);
    }

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        MainNavigationRouteNames.allCardsScreen,
      );
    }
  }
}
