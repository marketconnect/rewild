import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

import 'package:rewild/domain/entities/group_model.dart';

abstract class AllGroupsScreenGroupsService {
  Future<Resource<List<GroupModel>>> getAll();
}

class AllGroupsScreenViewModel extends ResourceChangeNotifier {
  final AllGroupsScreenGroupsService groupsProvider;

  AllGroupsScreenViewModel(
      {required this.groupsProvider, required super.context}) {
    _asyncInit();
  }

  void _asyncInit() async {
    final groups = await fetch(() => groupsProvider.getAll());
    if (groups == null) {
      return;
    }
    _groups = groups;
    if (context.mounted) {
      notifyListeners();
    }
  }

  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;
}
