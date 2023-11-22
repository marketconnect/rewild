import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/background_message.dart';

abstract class BackgroundNotificationsBackgroundMessageService {
  Future<Resource<List<BackgroundMessage>>> getAll();
}

class BackgroundNotificationsViewModel extends ResourceChangeNotifier {
  final BackgroundNotificationsBackgroundMessageService
      backgroundNotificationsBackgroundMessageService;

  BackgroundNotificationsViewModel(
      {required this.backgroundNotificationsBackgroundMessageService,
      required super.context,
      required super.internetConnectionChecker}) {
    _asyncInit();
  }

  List<BackgroundMessage>? _backgroundMessages;
  List<BackgroundMessage> get backgroundMessages => _backgroundMessages ?? [];

  Future<void> _asyncInit() async {
    final messages = await fetch(
        () => backgroundNotificationsBackgroundMessageService.getAll());
    if (messages == null) {
      return;
    }
    _backgroundMessages = messages;
    notify();
  }
}
