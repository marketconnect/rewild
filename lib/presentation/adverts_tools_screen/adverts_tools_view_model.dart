import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_model.dart';

abstract class AdvertsToolsAdvertService {
  Future<Resource<List<AdvertInfoModel>>> getByType(int type);
}

class AdvertsToolsViewModel extends ResourceChangeNotifier {
  final AdvertsToolsAdvertService advertService;
  AdvertsToolsViewModel(
      {required super.context,
      required super.internetConnectionChecker,
      required this.advertService}) {
    _asyncInit();
  }

  List<AdvertInfoModel> _adverts = [];

  List<AdvertInfoModel> get adverts => _adverts;

  void _asyncInit() async {
    final advs =
        await fetch(() => advertService.getByType(AdvertTypeConstants.auto));
    if (advs == null) {
      return;
    }

    _adverts = advs;
    notify();
  }
}
