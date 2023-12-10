import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rewild/core/constants/image_constant.dart';

import 'package:rewild/core/utils/extensions/strings.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/presentation/single_group_screen/single_groups_screen_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/custom_image_view.dart';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/network_image.dart';

class SingleGroupScreen extends StatelessWidget {
  const SingleGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleGroupScreenViewModel>();
    final name = model.name;
    return SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(name.capitalize()),
              bottom: TabBar(splashFactory: NoSplash.splashFactory, tabs: [
                SizedBox(
                  width: model.screenWidth * 0.5,
                  child: const Tab(
                    child: Text('Заказы'),
                  ),
                ),
                SizedBox(
                  width: model.screenWidth * 0.5,
                  child: const Tab(
                    child: Text('Остатки'),
                  ),
                ),
              ]),
            ),
            body: const TabBarView(children: [
              _TabBody(
                isOrder: true,
              ),
              _TabBody(),
            ]),
          )),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({
    this.isOrder = false,
  });

  final bool isOrder;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleGroupScreenViewModel>();
    final cards = model.cards;
    final isExpanded = model.isExpanded;
    final changeExpanded = model.changeIsExpanded;
    final ordersDataMap = model.ordersDataMap;
    final stocksDataMap = model.stocksDataMap;
    final ordersTotal = model.ordersTotal;
    final stocksTotal = model.stocksTotal;

    if (cards == null || ordersDataMap.isEmpty || stocksDataMap.isEmpty) {
      return const EmptyWidget(
        text: "Нет групп",
      );
    }
    double turns = isExpanded ? 0.0 : 0.5;
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              changeExpanded();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: model.screenWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 300),
                            turns: turns,
                            child: const Icon(
                              Icons.keyboard_arrow_up_outlined,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    const SizedBox(
                      height: 35,
                    ),
                  _Chart(
                    dataMap: isOrder ? ordersDataMap : stocksDataMap,
                    total: isOrder ? ordersTotal : stocksTotal,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: model.screenWidth,
            height: 10,
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          ),
          _CardsList(
            isOrder: isOrder,
          )
        ],
      ),
    );
  }
}

class _CardsList extends StatelessWidget {
  const _CardsList({required this.isOrder});
  final bool isOrder;
  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleGroupScreenViewModel>();
    List<CardOfProductModel>? cards = model.cards;
    final ordersTotal = model.ordersTotal;
    final stocksTotal = model.stocksTotal;
    final delete = model.deleteCardFromGroup;
    // final cardStock = model.cardStocks;
    if (cards != null && isOrder) {
      cards = cards.where((card) => card.ordersSum > 0).toList();
    } else if (cards != null && !isOrder) {
      cards = cards.where((card) => card.stocksFbw > 0).toList();
    }
    if (cards == null) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomImageView(
          svgPath: ImageConstant.imgNotFound,
          height: model.screenHeight * 0.2,
          width: model.screenWidth * 0.5,
        ),
        SizedBox(
          height: model.screenHeight * 0.02,
        ),
        const Text(
          'Вы не добавили ни одной карточки в группу',
        ),
      ]));
    }

    if (isOrder) {
      cards.sort((a, b) => b.ordersSum.compareTo(a.ordersSum));
    } else {
      cards.sort((a, b) => b.stocksFbw.compareTo(a.stocksFbw));
    }
    return SingleChildScrollView(
      child: Column(
          children: cards.map((card) {
        // iteration =========================================================== iteration
        double part = 0;

        if (isOrder) {
          if (card.ordersSum > 0) {
            part = (card.ordersSum / ordersTotal) * 100;
          }
        } else {
          part = (card.stocksFbw / stocksTotal) * 100;
        }

        return Slidable(
          startActionPane: ActionPane(
            dragDismissible: false,
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () {}),

            // All actions are defined in the children parameter.
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                onPressed: (BuildContext context) async =>
                    await delete(card.nmId),
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onTertiaryContainer,
                icon: Icons.remove_circle,
                label: 'Убрать',
              ),
            ],
          ),

          // The end action pane is the one at the right or the bottom side.
          endActionPane: ActionPane(
            dragDismissible: false,
            // dismissible: ,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) =>
                    Navigator.of(context).pushNamed(
                  MainNavigationRouteNames.singleCardScreen,
                  arguments: card.nmId,
                ),
                // (BuildContext context) async => await Share.share(
                //   'https://www.wildberries.ru/catalog/${card.nmId}/detail.aspx',
                // ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                icon: Icons.open_in_new,
                label: 'Открыть',
              ),
            ],
          ),

          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ReWildNetworkImage(
                        width: model.screenWidth * 0.2,
                        height: model.screenWidth * 0.2,
                        fit: BoxFit.contain,
                        image: card.img ?? ''),
                    // SizedBox(
                    //     width: model.screenWidth * 0.2,
                    //     height: model.screenWidth * 0.2,
                    //     child:
                    //     CachedNetworkImage(imageUrl: card.img ?? '')),
                    SizedBox(
                      width: model.screenWidth * 0.45,
                      child: Text(card.name, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                Container(
                  width: model.screenWidth * 0.12,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: card.seller!.backgroundColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${part.toStringAsFixed(0)}%',
                    style: TextStyle(color: card.seller!.fontColor),
                  ),
                ),
                Text('${isOrder ? card.ordersSum : card.stocksFbw}'),
              ],
            ),
          ),
        );
      }).toList()),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({
    required this.dataMap,
    required this.total,
  });

  final Map<SellerModel, double> dataMap;
  final int total;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleGroupScreenViewModel>();
    final expanded = model.isExpanded;
    List<Color> colorsList = [];
    Map<String, double> data = <String, double>{};
    for (final entry in dataMap.entries) {
      data[entry.key.name] = entry.value;
      colorsList.add(entry.key.backgroundColor!);
    }

    if (dataMap.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      width: model.screenWidth,
      height: expanded ? null : model.screenHeight * 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: PieChart(
          dataMap: data,
          ringStrokeWidth: 30,
          centerText: 'Всего\n$total шт.',
          legendOptions: LegendOptions(
            showLegends: expanded,
            legendPosition: LegendPosition.bottom,
          ),
          chartValuesOptions: const ChartValuesOptions(
              showChartValues: true,
              decimalPlaces: 1,
              showChartValuesInPercentage: true,
              chartValueBackgroundColor: Colors.transparent),
          chartType: ChartType.ring,
          colorList: colorsList,
        ),
      ),
    );
  }
}
