import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

import 'package:rewild/domain/entities/group_model.dart';

abstract class AllGroupsScreenGroupsService {
  Future<Resource<List<GroupModel>>> getAll();
  Future<Resource<void>> deleteGroup(String groupName);
  Future<Resource<void>> renameGroup(String groupName, String newGroupName);
}

abstract class AllGroupsScreenUpdateService {
  Future<Resource<void>> update();
}

class AllGroupsScreenViewModel extends ResourceChangeNotifier {
  final AllGroupsScreenGroupsService groupsProvider;
  final AllGroupsScreenUpdateService updateService;

  AllGroupsScreenViewModel({
    required this.groupsProvider,
    required this.updateService,
    required super.context,
    required super.internetConnectionChecker,
  }) {
    _asyncInit();
  }

  void _asyncInit() async {
    final groups = await fetch(() => groupsProvider.getAll());
    if (groups == null) {
      return;
    }
    // Update
    if (isConnected) {
      await fetch(() => updateService.update());
    }
    _groups = groups;
    if (context.mounted) {
      notifyListeners();
    }
  }

  Future<void> rename(String oldName, String newName) async {
    await fetch(() => groupsProvider.renameGroup(oldName, newName));

    _asyncInit();
  }

  Future<void> delete(String name) async {
    await fetch(() => groupsProvider.deleteGroup(name));
    _asyncInit();
  }

  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;
}
