import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/background_message.dart';
import 'package:rewild/presentation/background_messages_screen/background_messages_view_model.dart';

abstract class BackgroundMessageServiceBackgroundDataProvider {
  Future<Resource<bool>> delete(int id, int subject, int condition);
  Future<Resource<List<BackgroundMessage>>> getAll();
}

class BackgroundMessageService
    implements BackgroundMessagesBackgroundMessageService {
  final BackgroundMessageServiceBackgroundDataProvider
      backgroundMessageDataProvider;

  BackgroundMessageService({required this.backgroundMessageDataProvider});

  @override
  Future<Resource<bool>> delete(int id, int subject, int condition) async {
    return await backgroundMessageDataProvider.delete(id, subject, condition);
  }

  @override
  Future<Resource<List<BackgroundMessage>>> getAll() async {
    return await backgroundMessageDataProvider.getAll();
  }
}
