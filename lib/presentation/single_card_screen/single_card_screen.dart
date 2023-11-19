import 'package:auto_size_text/auto_size_text.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/progress_indicator.dart';

import 'package:url_launcher/url_launcher.dart';

class SingleCardScreen extends StatelessWidget {
  const SingleCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final listTilesNames = model.listTilesNames;

    final isNull = model.isNull;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).pushNamed(
                  MainNavigationRouteNames.cardNotificationsSettingsScreen),
              icon: Icon(
                Icons.notification_add_outlined,
                color: Theme.of(context).colorScheme.primary,
              ))
        ],
      ),
      body: isNull
          ? const Center(
              child: MyProgressIndicator(),
            )
          : SizedBox(
              width: model.screenWidth,
              child: SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Column(children: [
                  const _MainPicture(),
                  Column(
                    children: [
                      SizedBox(
                        height: model.screenHeight * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: model.screenWidth * 0.05),
                        child: const _Feedback(),
                      ),
                      SizedBox(
                        height: model.screenHeight * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: model.screenWidth * 0.05),
                        child: const _Name(),
                      ),
                      SizedBox(
                        height: model.screenHeight * 0.02,
                      ),
                      Divider(
                          color: Theme.of(context).colorScheme.surfaceVariant),
                      ListView.builder(
                          itemCount: listTilesNames.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return _ExpansionTile(
                              index: index,
                            );
                          }),
                    ],
                  ),
                ]),
              ),
            ),
    ));
  }
}

class _ExpansionTile extends StatelessWidget {
  const _ExpansionTile({
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final getTitle = model.getTitle;
    List<Widget> children = _getContent(model, context);
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.surfaceVariant))),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedTextColor: Theme.of(context).colorScheme.onSurface,
          textColor: Theme.of(context).colorScheme.onSurface,
          collapsedIconColor: Theme.of(context).colorScheme.onSurface,
          iconColor: Theme.of(context).colorScheme.onSurface,
          title: Text(
            getTitle(index),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: model.screenWidth * 0.05,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          children: [
            ...children,
            SizedBox(
              height: model.screenHeight * 0.05,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _getContent(
      SingleCardScreenViewModel model, BuildContext context) {
    List<Widget> children = [];
    if (index == 0) {
      // Общая информация
      List<_InfoRowContent> widgetsContent = [];
      final sellerName = model.sellerName;

      final brand = model.brand;
      final tradeMark = model.tradeMark;

      final region = model.region;

      widgetsContent.addAll([
        _InfoRowContent(header: "Продавец", text: sellerName),
        _InfoRowContent(header: "Регион регистрации", text: region),
        _InfoRowContent(header: "Брэнд", text: brand),
        _InfoRowContent(header: "Торг. марка", text: tradeMark),
      ]);

      children = widgetsContent
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: widgetsContent.indexOf(e) % 2 != 0,
              ))
          .toList();
    } else if (index == 1) {
      // Карточка
      final category = model.category;
      final subject = model.subject;
      final ordersSum = model.totalOrdersQty;
      final isHighBuyout = model.isHighBuyout;
      final commision = model.commission;
      List<_InfoRowContent> widgetsContent = [];
      widgetsContent.addAll([
        _InfoRowContent(header: "Категория", text: category),
        _InfoRowContent(header: "Предмет", text: subject)
      ]);
      if (commision != null) {
        widgetsContent.add(_InfoRowContent(
            header: "Комиссия WB", text: '${commision.toString()}%'));
      }
      if (ordersSum != null) {
        widgetsContent.add(_InfoRowContent(
            header: "Всего заказов", text: "более $ordersSum шт."));
      }

      if (isHighBuyout) {
        if (widgetsContent.length % 2 == 0) {
          widgetsContent.insert(
              widgetsContent.length - 1,
              _InfoRowContent(
                  header: "Высокий % выкупов",
                  text: "",
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.check_circle_outline_outlined,
                        size: 30,
                        color: Colors.greenAccent,
                      ),
                    ],
                  )));
        } else {
          widgetsContent.add(_InfoRowContent(
              header: "Высокий % выкупов",
              text: "",
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.check_circle_outline_outlined,
                    size: 30,
                    color: Colors.greenAccent,
                  ),
                ],
              )));
        }
      }

      children = widgetsContent
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: widgetsContent.indexOf(e) % 2 != 0,
              ))
          .toList();
    } else if (index == 2) {
      // Остатки
      final wareHouses = model.warehouses;
      final supplies = model.supplies;

      if (wareHouses.length > 1) {
        wareHouses['Все склады'] = model.stocksSum;
      }
      final List<_InfoRowContent> rowsContents = [];

      wareHouses.forEach((k, v) {
        rowsContents.add(
          _InfoRowContent(
            header: k,
            text: supplies[k] != null && supplies[k]! > 0
                ? '(+${supplies[k]!}) $v шт.'
                : '$v шт.',
          ),
        );
      });
      children = rowsContents
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: rowsContents.indexOf(e) % 2 != 0,
              ))
          .toList();
    }
    if (index == 3) {
      // Заказы
      final orders = model.orders;

      if (orders.length > 1) {
        orders['Все склады'] =
            model.initStocksSum + model.supplySum - model.stocksSum;
      }
      List<_InfoRowContent> widgetsContent = [];

      orders.forEach((whName, sales) {
        widgetsContent.add(
          _InfoRowContent(
              header: whName,
              text: sales > 0
                  ? '$sales шт.'
                  : sales == 0
                      ? '-'
                      : sales < -NumericConstants.supplyThreshold
                          ? 'поставка ${-sales} шт.'
                          : 'возврат ${-sales} шт.'),
        );
      });

      children = widgetsContent
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: widgetsContent.indexOf(e) % 2 != 0,
              ))
          .toList();
    }
    return children;
  }
}

class _InfoRowContent {
  final String header;
  final String text;
  final Widget? child;

  _InfoRowContent({
    required String header,
    required this.text,
    this.child,
  }) : header = header.contains("склад продавца")
            ? "${header.replaceFirst("склад продавца", "")} (скл. пр.)"
            : header;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.content,
    required this.parentContext,
    this.isDark = false,
  });

  final _InfoRowContent content;
  final bool isDark;

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    return Container(
      width: model.screenWidth,
      height: model.screenHeight * 0.07,
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(parentContext)
                .colorScheme
                .surfaceVariant
                .withOpacity(0.3)
            : Theme.of(parentContext).colorScheme.background,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: model.screenWidth * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: model.screenWidth * 0.3,
              child: AutoSizeText(
                content.header,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: model.screenWidth * 0.04,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
              ),
            ),
            SizedBox(
              width: model.screenWidth * 0.6,
              child: content.child ??
                  AutoSizeText(
                    content.text,
                    textAlign: TextAlign.end,
                    maxLines: 3,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: model.screenWidth * 0.04,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5)),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Name extends StatelessWidget {
  const _Name();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final text = context.watch<SingleCardScreenViewModel>().name;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: model.screenWidth * 0.9,
          child: Text(
            text,
            textAlign: TextAlign.left,
            maxLines: 5,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: model.screenWidth * 0.06,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final feedbacks = model.feedbacks;
    final reviewRating = model.reviewRating;

    final link = model.websiteUri;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '$reviewRating',
              style: TextStyle(
                  fontSize: model.screenWidth * 0.04,
                  color: Theme.of(context).colorScheme.primary),
            ),
            Icon(
              Icons.star,
              size: model.screenWidth * 0.04,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(
              width: model.screenWidth * 0.02,
            ),
            Text(
              '$feedbacks',
              style: TextStyle(
                  fontSize: model.screenWidth * 0.04,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            if (link == null) {
              return;
            }
            var urllaunchable = await canLaunchUrl(
                link); //canLaunch is from url_launcher package
            if (urllaunchable) {
              await launchUrl(
                  link); //launch is from url_launcher package to launch URL
            }
          },
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: model.screenWidth * 0.01),
                child: Text(
                  'Перейти',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: model.screenWidth * 0.035,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5)),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: model.screenWidth * 0.07,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _MainPicture extends StatelessWidget {
  const _MainPicture();

  @override
  Widget build(BuildContext context) {
    final img = context.watch<SingleCardScreenViewModel>().img;

    if (img.isEmpty) {
      return const MyProgressIndicator();
    }
    return SizedBox(
      child: CachedNetworkImage(
          fit: BoxFit.cover,
          errorWidget: ((context, url, error) =>
              const Icon(Icons.error_outlined, size: 50)),
          imageUrl: img),
    );
  }
}
