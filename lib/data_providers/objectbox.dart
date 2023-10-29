// import 'package:rewild/core/utils/resource.dart';
// import 'package:rewild/domain/entities/card_of_product_model.dart';
// import 'package:rewild/domain/entities/group_model.dart';
// import 'package:rewild/domain/entities/initial_stock_model.dart';
// import 'package:rewild/domain/entities/seller_model.dart';
// import 'package:rewild/domain/entities/size_model.dart';
// import 'package:rewild/domain/entities/stocks_model.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;

// import 'package:rewild/objectbox.g.dart';

// class ObjectBox {
//   late final Store store;
//   // Boxes
//   late final Box<CardOfProductModel> cardOfProductModelBox;
//   late final Box<StocksModel> stocksModelBox;

//   late final Box<InitialStockModel> initialStockModelBox;
//   late final Box<SizeModel> sizeModelBox;
//   late final Box<GroupModel> groupModelBox;
//   late final Box<SellerModel> sellerModelBox;

//   ObjectBox._create(this.store) {
//     cardOfProductModelBox = store.box<CardOfProductModel>();
//     stocksModelBox = store.box<StocksModel>();

//     initialStockModelBox = store.box<InitialStockModel>();
//     sizeModelBox = store.box<SizeModel>();
//     groupModelBox = store.box<GroupModel>();
//     sellerModelBox = store.box<SellerModel>();
//   }

//   static Future<ObjectBox> create() async {
//     final store = await openStore(
//         directory: p.join(
//             (await getApplicationDocumentsDirectory()).path, "obx-demo"));
//     return ObjectBox._create(store);
//   }

//   Resource<SellerModel> getSellerBySupplierId(int supplierId) {
//     try {
//       final sellersQuery = sellerModelBox
//           .query(SellerModel_.sellerId.equals(supplierId))
//           .build();
//       final sellers = sellersQuery.find();
//       sellersQuery.close();
//       if (sellers.isEmpty) {
//         return Resource.empty();
//       }

//       return Resource.success(sellers.first);
//     } catch (e) {
//       return Resource.error(e.toString());
//     }
//   }

//   // CardOfProductModel
//   Resource<List<CardOfProductModel>> getAll() {
//     try {
//       final cards = cardOfProductModelBox.getAll();

//       return Resource.success(cards);
//     } catch (e) {
//       return Resource.error(e.toString());
//     }
//   }

//   Resource<int> getNmid(int id) {
//     try {
//       final card = cardOfProductModelBox.get(id);
//       return Resource.success(card!.nmId);
//     } catch (e) {
//       return Resource.error(e.toString());
//     }
//   }

//   Resource<List<CardOfProductModel>> getAllByGroup(int groupId) {
//     try {
//       // final query = groupModelBox.query(GroupModel_.id.equals(groupId)).build();
//       GroupModel? group = groupModelBox.get(groupId);
//       if (group == null) {
//         return Resource.error('Группы не существует');
//       }
//       final cards = group.cards;
//       return Resource.success(cards);
//     } catch (e) {
//       return Resource.error(e.toString());
//     }
//   }

//   Resource<int> insertOrUpdate(CardOfProductModel card) {
//     try {
//       CardOfProductModel? storedCard = cardOfProductModelBox.get(card.nmId);
//       if (storedCard != null) {
//         return _update(storedCard, card);
//       }
//       return _insert(card);
//     } catch (e) {
//       return Resource.error(
//           'Не удалось сохранить карточку id ${card.nmId} в память телефона: ${e.toString()}');
//     }
//   }

//   Resource<int> _update(
//       CardOfProductModel storedCard, CardOfProductModel updatedCard) {
//     try {
//       print("_update");
//       // update fields
//       storedCard.basicPriceU = updatedCard.basicPriceU;
//       storedCard.pics = updatedCard.pics;
//       storedCard.rating = updatedCard.rating;
//       storedCard.reviewRating = updatedCard.reviewRating;
//       storedCard.subjectId = updatedCard.subjectId;
//       storedCard.subjectParentId = updatedCard.subjectParentId;
//       storedCard.supplierId = updatedCard.supplierId;
//       storedCard.brand = updatedCard.brand;
//       storedCard.name = updatedCard.name;
//       storedCard.tradeMark = updatedCard.tradeMark;
//       storedCard.img = updatedCard.img;
//       storedCard.sellerId = updatedCard.sellerId;
//       storedCard.promoTextCard = updatedCard.promoTextCard;

//       // update relationships

//       // clear stocks
//       for (final size in storedCard.sizes) {
//         for (final stock in size.stocks) {
//           stocksModelBox.remove(stock.id);
//         }
//       }

//       // clear sizes
//       storedCard.sizes.clear();

//       // add sizes with stocks ???
//       storedCard.sizes.addAll(updatedCard.sizes);

//       // add seller
//       if (updatedCard.seller.target != null) {
//         storedCard.seller.target = updatedCard.seller.target;
//       }

//       // add initial stocks
//       storedCard.initialStocks.clear();
//       storedCard.initialStocks.addAll(updatedCard.initialStocks);

//       // save
//       final id = cardOfProductModelBox.put(storedCard);
//       return Resource.success(id);
//     } catch (e) {
//       return Resource.error(e.toString());
//     }
//   }

//   Resource<int> _insert(CardOfProductModel card) {
//     try {
//       final id = cardOfProductModelBox.put(card);
//       return Resource.success(id);
//     } catch (e) {
//       return Resource.error(e.toString());
//     }
//   }

//   Resource<bool> drop(int id) {
//     try {
//       final isRemoved = cardOfProductModelBox.remove(id);

//       return Resource.success(isRemoved);
//     } on Exception catch (e) {
//       return Resource.error(
//           'Не удалось удалить карточку из памяти телефона: ${e.toString()}');
//     }
//   }

//   Resource<CardOfProductModel?> getOne(int id) {
//     try {
//       final card = cardOfProductModelBox.get(id);

//       return Resource.success(card);
//     } on Exception catch (e) {
//       return Resource.error(
//           'Не удалось получить карточку из локальной памяти: ${e.toString()}');
//     }
//   }

//   Resource<int> insertInitialStocks(
//       int cardId, List<InitialStockModel> initialStocksModels) {
//     try {
//       CardOfProductModel? card = cardOfProductModelBox.get(cardId);
//       if (card == null) {
//         return Resource.error('Карточки с id $cardId не существует');
//       }
//       for (final initialStock in initialStocksModels) {
//         card.initialStocks.add(initialStock);
//       }
//       final id = cardOfProductModelBox.put(card);
//       return Resource.success(id);
//     } on Exception catch (e) {
//       return Resource.error(
//           'Не удалось добавить остатки в память телефона: ${e.toString()}');
//     }
//   }

//   Resource<int> addGroup(GroupModel group) {
//     try {
//       final id = groupModelBox.put(group);
//       return Resource.success(id);
//     } on Exception catch (e) {
//       return Resource.error(
//           'Не удалось добавить группу в память телефона: ${e.toString()}');
//     }
//   }

//   Resource<List<GroupModel>> getAllGroups() {
//     try {
//       final groups = groupModelBox.getAll();
//       // print(groups[0].name);
//       return Resource.success(groups);
//     } on Exception catch (e) {
//       return Resource.error(
//           'Не удалось получить группы из локальной памяти: ${e.toString()}');
//     }
//   }

//   Resource<int> addGroupInCard(int groupId, int cardId) {
//     try {
//       CardOfProductModel? card = cardOfProductModelBox.get(cardId);
//       if (card == null) {
//         print('card not found');
//         return Resource.error('Карточки с id $cardId не существует');
//       }
//       GroupModel? group = groupModelBox.get(groupId);
//       if (group == null) {
//         print('group not found');
//         return Resource.error('Группы с id $groupId не существует');
//       }

//       List<GroupModel> groupsOfCard = card.groups;
//       if (groupsOfCard.contains(group)) {
//         print('group already in card');
//         return Resource.success(0);
//       }
//       card.groups.add(group);
//       print('add group ${group.name} to card ${card.nmId}');
//       final id = cardOfProductModelBox.put(card);
//       return Resource.success(id);
//     } on Exception catch (e) {
//       return Resource.error(
//           'Не удалось добавить карточку в группу: ${e.toString()}');
//     }
//   }

//   Resource<int> removeGroupFromCard(int groupId, int cardId) {
//     try {
//       CardOfProductModel? card = cardOfProductModelBox.get(cardId);
//       if (card == null) {
//         return Resource.error('Карточки с id $cardId не существует');
//       }

//       GroupModel? group = groupModelBox.get(groupId);
//       if (group == null) {
//         return Resource.error('Группы с id $groupId не существует');
//       }

//       card.groups.remove(group);
//       final id = cardOfProductModelBox.put(card);
//       return Resource.success(id);
//     } on Exception catch (e) {
//       return Resource.error(
//           'Не удалось удалить карточку из группы: ${e.toString()}');
//     }
//   }

//   Resource<GroupModel> getGroup(int id) {
//     try {
//       final group = groupModelBox.get(id);
//       if (group == null) {
//         return Resource.error('Группы с id $id не существует');
//       }
//       return Resource.success(group);
//     } on Exception catch (e) {
//       return Resource.error(
//           'Не удалось получить группу из локальной памяти: ${e.toString()}');
//     }
//   }

//   Resource<Stream<int>> getCardsNum() {
//     final builer = cardOfProductModelBox.query();
//     return Resource.success(builer
//         .watch(triggerImmediately: true)
//         .map((query) => query.find().length));
//   }
// }
