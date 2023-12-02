import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/commission_model.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class CommissionServiceCommissionApiClient {
  Future<Resource<CommissionModel>> get(int id);
}

abstract class CommissionServiceCommissionDataProvider {
  Future<Resource<CommissionModel>> get(int id);
  Future<Resource<void>> insert(CommissionModel commission);
}

class CommissionService
    implements
        SingleCardScreenCommissionService,
        AllCardsFilterCommissionService {
  final CommissionServiceCommissionApiClient commissionApiClient;
  final CommissionServiceCommissionDataProvider commissionDataProvider;

  CommissionService(
      {required this.commissionApiClient,
      required this.commissionDataProvider});

  @override
  Future<Resource<CommissionModel>> get(int id) async {
    // get from local db
    final commissionResource = await commissionDataProvider.get(id);
    if (commissionResource is Error) {
      return Resource.error(commissionResource.message!,
          source: runtimeType.toString(), name: 'get', args: [id]);
    }
    if (commissionResource is Success) {
      return commissionResource;
    }
    // not found in local db
    // get from server
    final commissionFromServerResource = await commissionApiClient.get(id);
    if (commissionFromServerResource is Error) {
      return Resource.error(commissionFromServerResource.message!,
          source: runtimeType.toString(), name: 'get', args: [id]);
    }

    // save to local db
    final saveResource =
        await commissionDataProvider.insert(commissionFromServerResource.data!);
    if (saveResource is Error) {
      return Resource.error(saveResource.message!,
          source: runtimeType.toString(), name: 'get', args: [id]);
    }
    return Resource.success(commissionFromServerResource.data!);
  }
}
