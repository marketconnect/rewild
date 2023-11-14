import 'package:rewild/api_clients/advert_api_client.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/data_providers/auto_stat_data_provider/auto_stat_data_provider.dart';
import 'package:rewild/data_providers/pursued_data_provider/pursued_data_provider.dart';
import 'package:rewild/data_providers/secure_storage_data_provider.dart';

class BackgroundService {
  BackgroundService();

  static DateTime? autoLastReq;

  static fetchAll() async {
    final pursuedResource = await PursuedDataProvider.getAllInBackground();
    if (pursuedResource is Error) {
      return;
    }
    final pursuedList = pursuedResource.data!;
    final tokenResource =
        await SecureStorageProvider.getApiKeyFromBackground('Продвижение');
    if (tokenResource is Error || tokenResource is Empty) {
      return;
    }
    final token = tokenResource.data!;

    for (final pursued in pursuedList) {
      if (pursued.property == "auto") {
        // request to API
        if (autoLastReq != null) {
          await _ready(
              autoLastReq, APIConstants.autoStatNumsDurationBetweenReqInMs);
        }

        final advertResource = await AdvertApiClient.getAutoStatInBackground(
            token.token, pursued.parentId);
        autoLastReq = DateTime.now();
        if (advertResource is Error) {
          continue;
        }
        final advert = advertResource.data!;
        final saveResource =
            await AutoStatDataProvider.saveInBackground(advert);

        if (saveResource is Error) {
          continue;
        }
      }
    }
  }

  static Future<void> _ready(DateTime? lastReq, Duration duration) async {
    if (lastReq == null) {
      return;
    }
    while (DateTime.now().difference(lastReq) < duration) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return;
  }
}
