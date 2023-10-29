import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/entities/group_model.dart';
import 'package:flutter/material.dart';

abstract class AllGroupsScreenGroupsService {
  Future<Resource<List<GroupModel>>> getAll();
}

class AllGroupsScreenViewModel extends ChangeNotifier {
  final AllGroupsScreenGroupsService groupsProvider;
  final BuildContext context;

  AllGroupsScreenViewModel(
      {required this.groupsProvider, required this.context}) {
    _asyncInit();
  }

  void _asyncInit() async {
    final groupsResource = await groupsProvider.getAll();
    if (groupsResource is Error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(groupsResource.message!),
      ));
    }
    _groups = groupsResource.data!;
    notifyListeners();
  }

  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;
}
