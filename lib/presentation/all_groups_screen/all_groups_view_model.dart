import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

import 'package:rewild/domain/entities/group_model.dart';

abstract class AllGroupsScreenGroupsService {
  Future<Either<RewildError, List<GroupModel>?>> getAll([List<int>? nmIds]);
  Future<Either<RewildError, void>> deleteGroup({required String groupName});
  Future<Either<RewildError, void>> renameGroup(
      {required String groupName, required String newGroupName});
}

abstract class AllGroupsScreenUpdateService {
  Future<Either<RewildError, void>> update();
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
    setIsLoading(true);
    final groups = await fetch(() => groupsProvider.getAll());
    if (groups == null) {
      return;
    }
    // Update
    if (isConnected) {
      await fetch(() => updateService.update());
    }
    _groups = groups;
    setIsLoading(false);

    notify();
  }

  Future<void> rename(String oldName, String newName) async {
    await fetch(() =>
        groupsProvider.renameGroup(groupName: oldName, newGroupName: newName));

    _asyncInit();
  }

  Future<void> delete(String name) async {
    await fetch(() => groupsProvider.deleteGroup(groupName: name));
    _asyncInit();
  }

  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;

  bool _isloading = false;
  bool get isLoading => _isloading;
  void setIsLoading(bool value) {
    _isloading = value;
  }
}
