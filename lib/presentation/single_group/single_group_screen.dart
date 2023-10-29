import 'package:rewild/core/utils/image_constant.dart';
import 'package:rewild/core/utils/strings.dart';
import 'package:rewild/presentation/single_group/single_groups_screen_view_model.dart';
import 'package:rewild/widgets/custom_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

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
              bottom: TabBar(tabs: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const Tab(
                    child: Text('Остатки'),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const Tab(
                    child: Text('Заказы'),
                  ),
                )
              ]),
            ),
            body: const TabBarView(children: [
              _TabBody(),
              _TabBody(
                isOrder: true,
              ),
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
    final ordersDataMap = model.ordersDataMap;
    final stocksDataMap = model.stocksDataMap;
    final ordersTotal = model.ordersTotal;
    final stocksTotal = model.stocksTotal;
    final colorsList = model.colorsList;

    if (cards == null) {
      return const _EmptyWidget();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _Chart(
              dataMap: isOrder ? ordersDataMap : stocksDataMap,
              total: isOrder ? ordersTotal : stocksTotal,
              colorsList: colorsList),
          Container(
            width: MediaQuery.of(context).size.width,
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

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomImageView(
          svgPath: ImageConstant.imgNotFound,
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.5,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        const Text(
          'Вы не добавили ни одной карточки в группу',
        ),
      ],
    ));
  }
}

class _CardsList extends StatelessWidget {
  const _CardsList({required this.isOrder});
  final bool isOrder;
  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleGroupScreenViewModel>();
    final cards = model.cards;
    final ordersTotal = model.ordersTotal;
    final stocksTotal = model.stocksTotal;

    if (cards == null) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomImageView(
          svgPath: ImageConstant.imgNotFound,
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.5,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        const Text(
          'Вы не добавили ни одной карточки в группу',
        ),
      ]));
    }

    if (isOrder) {
      cards.sort((a, b) => b.ordersSum.compareTo(a.ordersSum));
    } else {
      cards.sort((a, b) => b.stocksSum.compareTo(a.stocksSum));
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
          part = (card.stocksSum / stocksTotal) * 100;
        }

        return Container(
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
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2,
                      child: CachedNetworkImage(imageUrl: card.img ?? '')),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Text(card.name, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.12,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: card.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${part.toStringAsFixed(0)}%',
                  style: TextStyle(color: card.fontColor),
                ),
              ),
              // SizedBox(width: MediaQuery.of(context).size.width * 0.1),
              Text('${isOrder ? card.ordersSum : card.stocksSum} ')
            ],
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
    required this.colorsList,
  });

  final Map<String, double> dataMap;
  final int total;
  final List<Color> colorsList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: PieChart(
          dataMap: dataMap,
          ringStrokeWidth: 30,
          centerText: 'Всего\n$total шт.',
          legendOptions: const LegendOptions(
            showLegends: false,
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValues: false,
          ),
          chartType: ChartType.ring,
          colorList: colorsList,
        ),
      ),
    );
  }
}
