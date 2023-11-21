import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/background_message.dart';

abstract class BackgroundMessageServiceBackgroundDataProvider {
  Future<Resource<bool>> delete(BackgroundMessage message);
  Future<Resource<List<BackgroundMessage>>> getAll();
}

class BackgroundMessageService {
  final BackgroundMessageServiceBackgroundDataProvider
      backgroundMessageDataProvider;

  BackgroundMessageService({required this.backgroundMessageDataProvider});

  Future<Resource<bool>> delete(BackgroundMessage message) async {
    return await backgroundMessageDataProvider.delete(message);
  }

  Future<Resource<List<BackgroundMessage>>> getAll() async {
    return await backgroundMessageDataProvider.getAll();
  }
}
