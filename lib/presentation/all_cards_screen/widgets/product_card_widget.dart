import 'package:rewild/core/utils/strings.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rewild/domain/entities/group_model.dart';

class ProductCardWidget extends StatelessWidget {
  const ProductCardWidget({
    super.key,
    required this.productCard,
    this.inAnyGroup = false,
    this.isSelected = false,
  });

  final CardOfProductModel productCard;
  final bool isSelected;
  final bool inAnyGroup;

  @override
  Widget build(BuildContext context) {
    final stocksSum = productCard.stocksSum;
    final salesSum = productCard.ordersSum;
    final price = productCard.basicPriceU ?? 0;
    final wasSaled = productCard.wasOrdered;
    final promoTextCard = productCard.promoTextCard;
    final supplySum = productCard.supplySum;
    final screenWidth = MediaQuery.of(context).size.width;

    final supplyText = productCard.supplies.isNotEmpty && supplySum > 0
        ? " (п. ~$supplySum шт.)"
        : "";

    String? salesSumText;
    if (salesSum > 0) {
      salesSumText = "Заказы: $salesSum шт.";
    } else if (salesSum < 0 && salesSum > -20) {
      salesSumText = "Возврат: ${salesSum.abs()} шт.";
    }

    return Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3))),
        color: isSelected
            ? Theme.of(context).colorScheme.surfaceVariant
            : Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CachedNetworkImage(imageUrl: productCard.img ?? ''),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: productCard.groups.isEmpty || inAnyGroup
                                ? screenWidth * 0.6
                                : screenWidth * 0.45,
                            child: Text(productCard.name,
                                overflow: TextOverflow.ellipsis),
                          ),
                          inAnyGroup
                              ? Container()
                              : _Groups(groups: productCard.groups)
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text('Остатки: $stocksSum шт.',
                              style: TextStyle(
                                  color: const Color(0xFFa1a1a2),
                                  fontSize: screenWidth * 0.035)),
                        ],
                      ),
                      salesSumText == null
                          ? Container()
                          : Row(
                              children: [
                                Row(
                                  children: [
                                    Text(salesSumText,
                                        style: TextStyle(
                                            color: const Color(0xFFa1a1a2),
                                            fontWeight: FontWeight.w600,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.035)),
                                    if (wasSaled)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(Icons.arrow_outward_rounded,
                                            size: 20, color: Color(0xFF34d058)),
                                      ),
                                    Text(
                                      supplyText,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035),
                                    )
                                  ],
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: screenWidth * 0.15,
              child: Column(
                children: [
                  Text('${(price / 100).floor()}₽',
                      style: TextStyle(fontSize: screenWidth * 0.03)),
                  if (promoTextCard != null && promoTextCard != "")
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                        alignment: Alignment.center,
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Theme.of(context).colorScheme.errorContainer,
                        ),
                        child: Text("Акция",
                            style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Theme.of(context).colorScheme.error))),
                ],
              ),
            )
          ],
        ));
  }
}

class _Groups extends StatelessWidget {
  const _Groups({
    required this.groups,
  });

  final List<GroupModel> groups;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
        children: groups.isEmpty
            ? [Container()]
            : [
                Container(
                  alignment: Alignment.center,
                  width: screenWidth * 0.1,
                  height: 18,
                  decoration: BoxDecoration(
                      color: Color(groups[0].bgColor).withOpacity(1.0),
                      borderRadius: BorderRadius.circular(10)),
                  child: SizedBox(
                    width: screenWidth * 0.08,
                    child: Text(groups[0].name.take(4).toLowerCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Color(groups[0].fontColor),
                        )),
                  ),
                ),
                groups.length > 1
                    ? Text(
                        '+${groups.length - 1}',
                        style: const TextStyle(
                          fontSize: 7,
                          color: Color(0xFF1f1f1f),
                        ),
                      )
                    : Container(),
              ]);
  }
}
