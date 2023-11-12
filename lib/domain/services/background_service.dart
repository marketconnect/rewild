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
    print("fetchall");
    final pursuedResource = await PursuedDataProvider.getAllInBackground();
    if (pursuedResource is Error) {
      return;
    }
    final pursuedList = pursuedResource.data!;
    print("pursuedList: ${pursuedList.length}");
    final tokenResource =
        await SecureStorageProvider.getApiKeyFromBackground('Продвижение');
    if (tokenResource is Error || tokenResource is Empty) {
      return;
    }
    final token = tokenResource.data!;

    print("token: $token");
    for (final pursued in pursuedList) {
      print("p: ${pursued.parentId} - p: ${pursued.property}");
      if (pursued.property == "auto") {
        print("here");
        // request to API
        if (autoLastReq != null) {
          await _ready(
              autoLastReq, APIConstants.autoStatNumsDurationBetweenReqInMs);
        }

        final advertResource = await AdvertApiClient.getAutoStatInBackground(
            token.token, pursued.parentId);
        autoLastReq = DateTime.now();
        print('advertResource.data ${advertResource.data} ${pursued.parentId}');
        if (advertResource is Error) {
          print("error ${advertResource.message}!!!!");
          continue;
        }
        final advert = advertResource.data!;
        final saveResource =
            await AutoStatDataProvider.saveInBackground(advert);

        if (saveResource is Error) {
          print("savedresource error");
          continue;
        }
        print("added ${advert.advertId} at ${advert.createdAt}");
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
