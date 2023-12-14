import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/background_message.dart';
import 'package:rewild/presentation/app/app.dart';
import 'package:rewild/presentation/background_messages_screen/background_messages_view_model.dart';

abstract class BackgroundMessageServiceBackgroundDataProvider {
  Future<Either<RewildError, bool>> delete(int id, int subject, int condition);
  Future<Either<RewildError, List<BackgroundMessage>>> getAll();
}

class BackgroundMessageService
    implements BackgroundMessagesBackgroundMessageService, AppMessagesService {
  final BackgroundMessageServiceBackgroundDataProvider
      backgroundMessageDataProvider;

  BackgroundMessageService({required this.backgroundMessageDataProvider});

  @override
  Future<Either<RewildError, bool>> delete(
      int id, int subject, int condition) async {
    return await backgroundMessageDataProvider.delete(id, subject, condition);
  }

  @override
  Future<Either<RewildError, List<BackgroundMessage>>> getAll() async {
    return await backgroundMessageDataProvider.getAll();
  }

  @override
  Future<Either<RewildError, bool>> isNotEmpty() async {
    final res = await getAll();

    if (res is Success) {
      return res.data!.isNotEmpty ? right(true) : right(false);
    }
    return right(false);
  }
}
