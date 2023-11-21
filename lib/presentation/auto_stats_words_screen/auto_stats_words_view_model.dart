import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/auto_stat_word.dart';

abstract class AutoStatsWordsAutoStatsService {
  Future<Resource<AutoStatWord>> getAutoStatWords(int advertId);
}

abstract class AutoStatsWordsAdvertService {
  Future<Resource<Advert>> advertInfo(int advertId);
}

class AutoStatsWordsViewModel extends ResourceChangeNotifier {
  final AutoStatsWordsAutoStatsService autoStatsWordsAutoStatsService;
  final AutoStatsWordsAdvertService autoStatsWordsAdvertService;
  final int advertId;
  AutoStatsWordsViewModel(this.advertId,
      {required super.context,
      required super.internetConnectionChecker,
      required this.autoStatsWordsAdvertService,
      required this.autoStatsWordsAutoStatsService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    final values = await Future.wait([
      fetch(() => autoStatsWordsAutoStatsService.getAutoStatWords(advertId)),
      fetch(() => autoStatsWordsAdvertService.advertInfo(advertId)),
    ]);

    // Advert Info
    final autoStatsWordRes = values[0] as AutoStatWord?;
    final advertInfo = values[1] as Advert?;
    if (autoStatsWordRes == null) {
      return;
    }

    _autoStatWord = autoStatsWordRes;
    if (advertInfo == null) {
      return;
    }
    _name = advertInfo.name;
    notify();
  }

  // Name
  String? _name;
  String? get name => _name ?? '';
  AutoStatWord? _autoStatWord;
  AutoStatWord? get autoStatWord => _autoStatWord;
}
