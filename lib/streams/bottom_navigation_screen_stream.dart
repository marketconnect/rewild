import 'dart:async';

import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/presentation/bottom_navigation_screen/bottom_navigation_view_model.dart';

class BottomNavigationStreamImpl implements BottomNavigationStream {
  // controllers

  // in the bottom navigation cards screen need to update the number of cards
  late final _numOfCardsController = StreamController<int>.broadcast();
  // in the bottom navigation adverts screen need to update the list of adverts
  // in situation when the user save an api key first time
  late final _advertsController = StreamController<List<Advert>>.broadcast();
  // in the bottom navigation adverts screen need to update apiKeyExists variable
  // in situation when the user save an api key first time
  late final _apiKeyExistsController = StreamController<bool>.broadcast();

  // streams
  @override
  Stream<bool> get apiKeyExistsSteam => _apiKeyExistsController.stream;

  @override
  Stream<int> get numOfCardsStream => _numOfCardsController.stream;

  @override
  Stream<List<Advert>> get advertsStream => _advertsController.stream;

  void updateNumOfCards(int message) {
    _numOfCardsController.add(message);
  }

  void updateAdverts(List<Advert> advert) {
    _advertsController.add(advert);
  }

  void updateApiKeyExists(bool message) {
    _apiKeyExistsController.add(message);
  }

  void dispose() {
    _numOfCardsController.close();
  }
}
