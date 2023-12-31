import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rewild/core/constants/icons_constant.dart';

import 'package:rewild/domain/entities/search_campaign_stat.dart';

class CardContent {
  final int orderNum;
  final String word;
  final String normQuery;
  final int dif;
  final bool isNew;
  final int? qty;
  Stat? stat;
  bool? highCost;

  CardContent(
      {required this.dif,
      required this.orderNum,
      required this.isNew,
      required this.word,
      required this.normQuery,
      this.qty,
      this.stat,
      this.highCost});
}

class SlidableContainer extends StatelessWidget {
  const SlidableContainer({
    super.key,
    required this.displayedContent,
  });

  final CardContent displayedContent;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(children: [
      displayedContent.stat == null
          ? _Container(
              screenHeight: screenHeight, displayedContent: displayedContent)
          : _ContainerWithStat(
              screenHeight: screenHeight,
              displayedContent: displayedContent,
              stat: displayedContent.stat!),
      Positioned(
          top: 0,
          right: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
            height: MediaQuery.of(context).size.width * 0.05,
            child: displayedContent.isNew
                ? Image.asset(
                    IconConstant.iconNew,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : AutoSizeText(
                    displayedContent.dif > 0 ? '+${displayedContent.dif}' : ''),
          ))
    ]);
  }
}

class _Container extends StatelessWidget {
  const _Container({
    required this.screenHeight,
    required this.displayedContent,
  });

  final double screenHeight;
  final CardContent displayedContent;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          top: 0,
          left: displayedContent.qty == null
              ? 0
              : MediaQuery.of(context).size.width * 0.02,
          child: Container(
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.surfaceVariant,
                width: 1,
              ),
              right: BorderSide(
                color: Theme.of(context).colorScheme.surfaceVariant,
                width: 1,
              ),
            )),
            child: Text(
              (displayedContent.orderNum + 1).toString(),
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.02,
              ),
            ),
          )),
      Container(
        height: screenHeight * 0.1,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant,
        ))),
        child: Row(
          children: [
            if (displayedContent.qty != null)
              Container(
                width: MediaQuery.of(context).size.width * 0.02,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Expanded(
              flex: displayedContent.qty != null ? 7 : 9,
              child: AutoSizeText(
                displayedContent.word,
                maxLines: 4,
              ),
            ),
            Expanded(flex: 1, child: Container()),
            if (displayedContent.qty != null)
              Expanded(
                flex: 2,
                child: AutoSizeText('${displayedContent.qty}'),
              ),
            if (displayedContent.qty == null)
              Container(
                width: MediaQuery.of(context).size.width * 0.02,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
          ],
        ),
      ),
    ]);
  }
}

class _ContainerWithStat extends StatelessWidget {
  const _ContainerWithStat({
    required this.screenHeight,
    required this.displayedContent,
    required this.stat,
  });

  final double screenHeight;
  final CardContent displayedContent;
  final Stat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: MediaQuery.of(context).size.width * 0.02),
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.surfaceVariant,
              ))),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              Expanded(
                flex: displayedContent.qty != null ? 7 : 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    AutoSizeText(
                      displayedContent.word,
                      maxLines: 4,
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Row(
                      children: [
                        Text("Статистика:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.9))),
                      ],
                    ),
                    _DetailsContainer(
                        title: "Стоимость клика:", value: "${stat.cpc}₽"),
                    _DetailsContainer(title: "Частота:", value: "${stat.frq}"),
                    _DetailsContainer(
                        title: "Потрачено:",
                        value: '${stat.sum.toStringAsFixed(2)}₽'),
                    _DetailsContainer(title: "Клики:", value: "${stat.clicks}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("CTR:",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.9))),
                        Text("${stat.ctr}",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.9))),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(flex: 1, child: Container()),
              if (displayedContent.qty != null)
                Expanded(
                  flex: 2,
                  child: AutoSizeText('${displayedContent.qty}'),
                ),
              if (displayedContent.qty == null)
                Container(
                  width: MediaQuery.of(context).size.width * 0.02,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsContainer extends StatelessWidget {
  const _DetailsContainer({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.2)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.9))),
          Text(value,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.9))),
        ],
      ),
    );
  }
}
