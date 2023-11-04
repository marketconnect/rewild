import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/advert_model.dart';

abstract class AdvertServiceAdvertDataProvider {
  Future<Resource<List<Advert>>> getAdvert(String token);
}

class AdvertService {
  final AdvertServiceAdvertDataProvider advertDataProvider;

  AdvertService({required this.advertDataProvider});

  Future<Resource<List<Advert>>> getAdvert(String token) async {
    return advertDataProvider.getAdvert(token);
  }
}
