import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_model.dart';

abstract class AllAdvertsToolsAdvertService {
  Future<Resource<List<AdvertInfoModel>>> getByType([int? type]);
}

class AllAdvertsToolsViewModel extends ResourceChangeNotifier {
  final AllAdvertsToolsAdvertService advertService;
  AllAdvertsToolsViewModel(
      {required super.context,
      required super.internetConnectionChecker,
      required this.advertService}) {
    _asyncInit();
  }

  List<AdvertInfoModel> _adverts = [];

  List<AdvertInfoModel> get adverts => _adverts;

  void _asyncInit() async {
    final advs = await fetch(() => advertService.getByType());
    if (advs == null) {
      return;
    }

    _adverts = advs;

    notify();
  }

  int _selectedAdvertType = AdvertTypeConstants.auto;

  int get selectedAdvertType => _selectedAdvertType;
  void selectAdvertType(int type) {
    _selectedAdvertType = type;
    notify();
  }

  List<int> existingAdvertsTypes() {
    return _adverts.map((e) => e.type).toList();
  }
}
