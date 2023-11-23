import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';
import 'package:rewild/presentation/single_advert_stats_screen/widgets/chart.dart';
import 'package:rewild/widgets/my_dialog_widget.dart';

class SingleAdvertStatsScreen extends StatefulWidget {
  const SingleAdvertStatsScreen({super.key});

  @override
  State<SingleAdvertStatsScreen> createState() =>
      _SingleAdvertStatsScreenState();
}

class _SingleAdvertStatsScreenState extends State<SingleAdvertStatsScreen> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleAdvertStatsViewModel>();
    final isActive = model.isActive;
    final cpm = model.cpm;
    final title = model.title;
    final openNotificationSettings = model.notificationsScreen;
    final changeCpm = model.changeCpm;
    final start = model.start;
    final decoration = BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant),
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.surface);

    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!isActive) {
                await start();
              } else {
                openNotificationSettings();
              }
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              isActive
                  ? Icons.notification_add_outlined
                  : Icons.play_arrow_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.97),
          appBar: AppBar(
            centerTitle: true,
            title: Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1f1f1f),
                ),
                textScaleFactor: 1),
            scrolledUnderElevation: 2,
            shadowColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            actions: [
              !isActive
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'не активна',
                        style: TextStyle(
                            fontSize: model.screenWidth * 0.035,
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return MyDialog(
                            header: "Ставка (СРМ, ₽)",
                            hint: '$cpm₽',
                            addGroup: changeCpm,
                            btnText: "Обновить",
                            description: "Введите новое значение ставки",
                            keyboardType: TextInputType.number,
                          );
                        },
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              width: model.screenWidth * 0.06,
                              height: model.screenWidth * 0.06,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius:
                                    BorderRadius.circular(model.screenWidth),
                              ),
                              child: Text(
                                "CPM",
                                style: TextStyle(
                                  fontSize: model.screenWidth * 0.015,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: model.screenWidth * 0.01,
                            ),
                            Text(
                              '$cpm₽',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
            ],
          ),
          body: SingleChildScrollView(
              // body ================================================== body //
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UpperContainer(decoration: decoration),
              SizedBox(
                height: model.screenWidth * 0.04,
              ),
              _BottomWidget(decoration)
            ],
          ))),
    );
  }
}

class _UpperContainer extends StatelessWidget {
  const _UpperContainer({
    required this.decoration,
  });

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleAdvertStatsViewModel>();
    return Container(
      margin: EdgeInsets.only(
          left: model.screenWidth * 0.04, top: model.screenWidth * 0.04),
      width: model.screenWidth * 0.92,
      height: model.screenHeight * 0.55,
      decoration: decoration,
      child: Column(children: [
        const _FirstRow(),
        Divider(
          color: Theme.of(context).colorScheme.surfaceVariant,
          height: 0,
        ),
        const Expanded(child: _SecondRow())
      ]),
    );
  }
}

class _SecondRow extends StatelessWidget {
  const _SecondRow();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleAdvertStatsViewModel>();
    final isActive = model.isActive;
    final autoStatsList = model.autoStatList;
    return IntrinsicHeight(
      child: Row(children: [
        SizedBox(
          height: double.infinity,
          width: model.screenWidth * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              autoStatsList.isEmpty || !isActive
                  ? Center(
                      child: Text(
                        "Нет данных",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.03),
                      ),
                    )
                  : Chart(
                      data: autoStatsList,
                    ),
              if (autoStatsList.isNotEmpty && isActive)
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: const Text("Показы"),
                ),
            ],
          ),
        ),
        Container(
          height: double.infinity,
          width: 1,
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        SizedBox(
            height: double.infinity,
            width: model.screenWidth * 0.45,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  autoStatsList.isEmpty || !isActive
                      ? Center(
                          child: Text(
                            "Нет данных",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03),
                          ),
                        )
                      : Chart(
                          data: autoStatsList,
                          clicks: true,
                        ),
                  if (autoStatsList.isNotEmpty && isActive)
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: const Text("Клики"),
                    )
                ]))
      ]),
    );
  }
}

class _BottomWidget extends StatelessWidget {
  const _BottomWidget(this.decoration);
  final BoxDecoration decoration;
  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleAdvertStatsViewModel>();

    final totalClicks = model.totalClicks;
    final totalViews = model.totalViews;
    final budget = model.budget;
    final ctr = model.totalCtr;
    final cpc = model.cpc;
    final ctrDiff = model.ctrDiff;
    return Container(
      decoration: decoration,
      height: model.screenHeight * 0.26,
      margin: EdgeInsets.only(left: model.screenWidth * 0.04),
      width: model.screenWidth * 0.92,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "Всего по кампании",
              style: TextStyle(fontSize: model.screenWidth * 0.05),
            ),
          ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _Cell(
                    title: "ПОКАЗЫ",
                    value: totalViews.toString(),
                    width: model.screenWidth),
                _Cell(
                    title: "CTR",
                    isCtr: true,
                    value: "$ctr${ctrDiff.isNotEmpty ? ' ($ctrDiff)' : ''}",
                    width: model.screenWidth),
                _Cell(
                    title: "КЛИКИ",
                    value: "$totalClicks",
                    width: model.screenWidth),
              ]),
              SizedBox(
                height: model.screenHeight * 0.03,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                _Cell(
                    title: "CPC",
                    value: cpc.toString(),
                    width: model.screenWidth),
                _Cell(
                    title: "БЮДЖЕТ",
                    value: '${budget.toString()}₽',
                    width: model.screenWidth),
              ]),
            ],
          )
        ],
      ),
    );
  }
}

class _FirstRow extends StatelessWidget {
  const _FirstRow();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleAdvertStatsViewModel>();
    final advertName = model.name;
    // final isPursued = model.isPursued;
    final views = model.views;
    final spentMoney = model.spentMoney;
    final clicks = model.clicks;
    final lastCtr = model.lastCtr.toStringAsFixed(2);
    // final ctrDiff = model.ctrDiff;
    return SizedBox(
      height: model.screenHeight * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              advertName,
              style: TextStyle(
                  fontSize: model.screenWidth * 0.045,
                  fontWeight: FontWeight.bold),
            )
          ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _Cell(
                    title: "ПОКАЗЫ",
                    value: views.toString(),
                    width: model.screenWidth),
                _Cell(
                    title: "CTR",
                    isCtr: true,
                    value: lastCtr,
                    width: model.screenWidth),
                _Cell(
                    title: "КЛИКИ",
                    value: clicks.toString(),
                    width: model.screenWidth),
              ]),
              SizedBox(
                height: model.screenHeight * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$spentMoney потрачено",
                    style: TextStyle(
                        fontSize: model.screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(
      {required this.title,
      required this.value,
      required this.width,
      this.isCtr = false});

  final String title;
  final String value;
  final double width;
  final bool isCtr;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width * 0.3,
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isCtr ? width * 0.05 : width * 0.03,
                  color: Theme.of(context).colorScheme.outline)),
          AutoSizeText(value,
              maxLines: 1,
              style: TextStyle(fontSize: isCtr ? width * 0.05 : width * 0.045)),
        ],
      ),
    );
  }
}
