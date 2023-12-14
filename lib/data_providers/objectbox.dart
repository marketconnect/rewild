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

//   Either<RewildError,SellerModel> getSellerBySupplierId(int supplierId) {
//     try {
//       final sellersQuery = sellerModelBox
//           .query(SellerModel_.sellerId.equals(supplierId))
//           .build();
//       final sellers = sellersQuery.find();
//       sellersQuery.close();
//       if (sellers.isEmpty) {
//         return right(null);
//       }

//       return right(sellers.first);
//     } catch (e) {
//       return left(RewildError(e.toString());
//     }
//   }

//   // CardOfProductModel
//   Either<RewildError,List<CardOfProductModel>> getAll() {
//     try {
//       final cards = cardOfProductModelBox.getAll();

//       return right(cards);
//     } catch (e) {
//       return left(RewildError(e.toString());
//     }
//   }

//   Either<RewildError,int> getNmid(int id) {
//     try {
//       final card = cardOfProductModelBox.get(id);
//       return right(card!.nmId);
//     } catch (e) {
//       return left(RewildError(e.toString());
//     }
//   }

//   Either<RewildError,List<CardOfProductModel>> getAllByGroup(int groupId) {
//     try {
//       // final query = groupModelBox.query(GroupModel_.id.equals(groupId)).build();
//       GroupModel? group = groupModelBox.get(groupId);
//       if (group == null) {
//         return left(RewildError('Группы не существует');
//       }
//       final cards = group.cards;
//       return right(cards);
//     } catch (e) {
//       return left(RewildError(e.toString());
//     }
//   }

//   Either<RewildError,int> insertOrUpdate(CardOfProductModel card) {
//     try {
//       CardOfProductModel? storedCard = cardOfProductModelBox.get(card.nmId);
//       if (storedCard != null) {
//         return _update(storedCard, card);
//       }
//       return _insert(card);
//     } catch (e) {
//       return left(RewildError(
//           'Не удалось сохранить карточку id ${card.nmId} в память телефона: ${e.toString()}');
//     }
//   }

//   Either<RewildError,int> _update(
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
//       return right(id);
//     } catch (e) {
//       return left(RewildError(e.toString());
//     }
//   }

//   Either<RewildError,int> _insert(CardOfProductModel card) {
//     try {
//       final id = cardOfProductModelBox.put(card);
//       return right(id);
//     } catch (e) {
//       return left(RewildError(e.toString());
//     }
//   }

//   Either<RewildError,bool> drop(int id) {
//     try {
//       final isRemoved = cardOfProductModelBox.remove(id);

//       return right(isRemoved);
//     } on Exception catch (e) {
//       return left(RewildError(
//           'Не удалось удалить карточку из памяти телефона: ${e.toString()}');
//     }
//   }

//   Either<RewildError,CardOfProductModel?> getOne(int id) {
//     try {
//       final card = cardOfProductModelBox.get(id);

//       return right(card);
//     } on Exception catch (e) {
//       return left(RewildError(
//           'Не удалось получить карточку из локальной памяти: ${e.toString()}');
//     }
//   }

//   Either<RewildError,int> insertInitialStocks(
//       int cardId, List<InitialStockModel> initialStocksModels) {
//     try {
//       CardOfProductModel? card = cardOfProductModelBox.get(cardId);
//       if (card == null) {
//         return left(RewildError('Карточки с id $cardId не существует');
//       }
//       for (final initialStock in initialStocksModels) {
//         card.initialStocks.add(initialStock);
//       }
//       final id = cardOfProductModelBox.put(card);
//       return right(id);
//     } on Exception catch (e) {
//       return left(RewildError(
//           'Не удалось добавить остатки в память телефона: ${e.toString()}');
//     }
//   }

//   Either<RewildError,int> addGroup(GroupModel group) {
//     try {
//       final id = groupModelBox.put(group);
//       return right(id);
//     } on Exception catch (e) {
//       return left(RewildError(
//           'Не удалось добавить группу в память телефона: ${e.toString()}');
//     }
//   }

//   Either<RewildError,List<GroupModel>> getAllGroups() {
//     try {
//       final groups = groupModelBox.getAll();
//       // print(groups[0].name);
//       return right(groups);
//     } on Exception catch (e) {
//       return left(RewildError(
//           'Не удалось получить группы из локальной памяти: ${e.toString()}');
//     }
//   }

//   Either<RewildError,int> addGroupInCard(int groupId, int cardId) {
//     try {
//       CardOfProductModel? card = cardOfProductModelBox.get(cardId);
//       if (card == null) {
//         print('card not found');
//         return left(RewildError('Карточки с id $cardId не существует');
//       }
//       GroupModel? group = groupModelBox.get(groupId);
//       if (group == null) {
//         print('group not found');
//         return left(RewildError('Группы с id $groupId не существует');
//       }

//       List<GroupModel> groupsOfCard = card.groups;
//       if (groupsOfCard.contains(group)) {
//         print('group already in card');
//         return right(0);
//       }
//       card.groups.add(group);
//       print('add group ${group.name} to card ${card.nmId}');
//       final id = cardOfProductModelBox.put(card);
//       return right(id);
//     } on Exception catch (e) {
//       return left(RewildError(
//           'Не удалось добавить карточку в группу: ${e.toString()}');
//     }
//   }

//   Either<RewildError,int> removeGroupFromCard(int groupId, int cardId) {
//     try {
//       CardOfProductModel? card = cardOfProductModelBox.get(cardId);
//       if (card == null) {
//         return left(RewildError('Карточки с id $cardId не существует');
//       }

//       GroupModel? group = groupModelBox.get(groupId);
//       if (group == null) {
//         return left(RewildError('Группы с id $groupId не существует');
//       }

//       card.groups.remove(group);
//       final id = cardOfProductModelBox.put(card);
//       return right(id);
//     } on Exception catch (e) {
//       return left(RewildError(
//           'Не удалось удалить карточку из группы: ${e.toString()}');
//     }
//   }

//   Either<RewildError,GroupModel> getGroup(int id) {
//     try {
//       final group = groupModelBox.get(id);
//       if (group == null) {
//         return left(RewildError('Группы с id $id не существует');
//       }
//       return right(group);
//     } on Exception catch (e) {
//       return left(RewildError(
//           'Не удалось получить группу из локальной памяти: ${e.toString()}');
//     }
//   }

//   Either<RewildError,Stream<int>> getCardsNum() {
//     final builer = cardOfProductModelBox.query();
//     return right(builer
//         .watch(triggerImmediately: true)
//         .map((query) => query.find().length));
//   }
// }
