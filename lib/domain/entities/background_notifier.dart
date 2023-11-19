import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/services/notification_content.dart';

abstract class BackgroundNotifier {
  List<NotificationContent> notifications(
    List<NotificationModel> notifications,
  );
}
