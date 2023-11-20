import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/auto_stat_word.dart';

abstract class AutoStatsWordsAutoStatsService {
  Future<Resource<AutoStatWord>> getAutoStatWords(int advertId);
}

class AutoStatsWordsViewModel extends ResourceChangeNotifier {
  final AutoStatsWordsAutoStatsService autoStatsWordsAutoStatsService;
  final int adveretId;
  AutoStatsWordsViewModel(this.adveretId,
      {required super.context,
      required super.internetConnectionChecker,
      required this.autoStatsWordsAutoStatsService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    final result = await fetch(
        () => autoStatsWordsAutoStatsService.getAutoStatWords(adveretId));
    if (result == null) {
      return;
    }

    _autoStatWord = result;
    print(_autoStatWord);
    notify();
  }

  AutoStatWord? _autoStatWord;
  AutoStatWord? get autoStatWord => _autoStatWord;
}
