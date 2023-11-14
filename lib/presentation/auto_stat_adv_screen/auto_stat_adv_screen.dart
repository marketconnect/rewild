import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rewild/domain/entities/auto_stat.dart';
import 'package:rewild/presentation/auto_stat_adv_screen/auto_stat_adv_view_model.dart';

class AutoStatAdvertScreen extends StatelessWidget {
  const AutoStatAdvertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutoStatViewModel>();
    final isActive = model.isActive;

    final cpm = model.cpm;
    // final isPursued = model.isPursued;

    final decoration = BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant),
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.surface);
    return SafeArea(
      child: Scaffold(
          floatingActionButton: isActive
              ? FloatingActionButton(
                  onPressed: () async {
                    _showModalBottomSheet(context, model);
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.track_changes,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(3),
                  width: model.screenWidth,
                  child: FloatingActionButton(
                    onPressed: () async {},
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text("Возобновить показы",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
                  )),
          floatingActionButtonLocation: isActive
              ? FloatingActionButtonLocation.endFloat
              : FloatingActionButtonLocation.centerDocked,
          backgroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.97),
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Автоматическая',
                style: TextStyle(
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
                      onTap: () => print("AGHGHJGHJ"),
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
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UpperContainer(decoration: decoration),
              SizedBox(
                height: model.screenWidth * 0.04,
              ),
              Container(
                margin: EdgeInsets.only(left: model.screenWidth * 0.04),
                width: model.screenWidth * 0.92,
                height: model.screenHeight * 0.3,
                decoration: decoration,
              )
            ],
          ))),
    );
  }

  Future<dynamic> _showModalBottomSheet(
      BuildContext context, AutoStatViewModel model) {
    final isPursued = model.isPursued;
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.background,
        context: context,
        builder: (context) => _ModalBottomWidget(
              isPursued: isPursued,
            ));
  }
}

class _ModalBottomWidget extends StatelessWidget {
  const _ModalBottomWidget({
    super.key,
    required this.isPursued,
  });

  final bool isPursued;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Icon(
                      Icons.close,
                      size: screenWidth * 0.05,
                    ),
                  ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  Tab(
                    // icon: Icon(Icons.chat_bubble),
                    text: "Общее",
                  ),
                  Tab(
                    // icon: Icon(Icons.video_call),
                    text: "Уведомления",
                  ),
                  Tab(
                    // icon: Icon(Icons.settings),
                    text: "A/B-тест",
                  )
                ],
              ),
            ),
            body: TabBarView(children: [
              Container(),
              Container(),
              Container(),
            ])
            // SizedBox(
            //   width: screenWidth,
            //   child: Row(
            //     children: [
            //       Text(
            //           "${isPursued ? 'Отключить отслеживание' : 'Включить отслеживание'}"),
            //     ],
            //   ),
            // ),
            // ],
            ),
      ),
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
    final model = context.watch<AutoStatViewModel>();
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
    final model = context.watch<AutoStatViewModel>();
    final autoStatsList = model.autoStatList;
    return IntrinsicHeight(
      child: Row(children: [
        SizedBox(
          height: double.infinity,
          width: model.screenWidth * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              autoStatsList.isEmpty
                  ? Center(
                      child: Text(
                        "Нет данных",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.03),
                      ),
                    )
                  : _Chart(
                      data: autoStatsList,
                    ),
              if (autoStatsList.isNotEmpty)
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
                  autoStatsList.isEmpty
                      ? Center(
                          child: Text(
                            "Нет данных",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03),
                          ),
                        )
                      : _Chart(
                          data: autoStatsList,
                          clicks: true,
                        ),
                  if (autoStatsList.isNotEmpty)
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: const Text("Клики"),
                    )
                ]))
      ]),
    );
    // return Column(
    //   children: [
    //     Row(
    //       children: [
    //         _Chart(
    //           data: autoStatsList,
    //         ),

    //         _Chart(
    //           data: autoStatsList,
    //           clicks: true,
    //         ),
    //       ],
    //     ),
    //     Row(children: [
    //       Container(
    //         alignment: Alignment.center,
    //         width: MediaQuery.of(context).size.width * 0.45,
    //         child: const Text("Показы"),
    //       ),
    //       Container(
    //         alignment: Alignment.center,
    //         width: MediaQuery.of(context).size.width * 0.45,
    //         child: const Text("Клики"),
    //       )
    //     ])
    //   ],
    // );
  }
}

class _Chart extends StatelessWidget {
  final List<AutoStatModel> data;

  _Chart({required this.data, this.clicks = false});
  final bool clicks;
  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.onPrimaryContainer,
    ];

    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      if (i == 0) {
        continue;
      }
      if (clicks) {
        double clicksDiff = data[i].clicks - data[i - 1].clicks;
        int viewsDiff = data[i].views - data[i - 1].views;
        final ctr = viewsDiff == 0 ? 0 : (clicksDiff / viewsDiff) * 100;
        spots.add(FlSpot(data[i].createdAt.millisecondsSinceEpoch.toDouble(),
            ctr.toDouble()));
        continue;
      }
      int viewsDiff = data[i].views - data[i - 1].views;
      spots.add(FlSpot(data[i].createdAt.millisecondsSinceEpoch.toDouble(),
          viewsDiff.toDouble()));
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LineChart(LineChartData(
          minY: 0,
          titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Format the x-axis labels (e.g., using time)
                        DateTime createdAt =
                            DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        String formattedTime =
                            '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
                        return RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              formattedTime,
                              style: const TextStyle(fontSize: 5),
                            ));
                      })),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                showTitles: false,
              )),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(
                showTitles: false,
              )),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      }))),
          borderData: FlBorderData(
            border: const Border(
              top: BorderSide.none,
              right: BorderSide.none,
              left: BorderSide(width: 1),
              bottom: BorderSide(width: 1),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    ColorTween(begin: gradientColors[0], end: gradientColors[1])
                        .lerp(0.2)!
                        .withOpacity(0.1),
                    ColorTween(begin: gradientColors[0], end: gradientColors[1])
                        .lerp(0.2)!
                        .withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class _FirstRow extends StatelessWidget {
  const _FirstRow();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutoStatViewModel>();
    final views = model.views;
    final spentMoney = model.spentMoney;
    final ctr = model.ctr;
    final ctrDiff = model.ctrDiff;
    return SizedBox(
      height: model.screenHeight * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Имя')]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _Cell(
                title: "ПОКАЗЫ",
                value: views.toString(),
                width: model.screenWidth),
            _Cell(
                title: "CTR",
                value: "$ctr${ctrDiff.isNotEmpty ? ' ($ctrDiff)' : ''}",
                width: model.screenWidth),
            _Cell(
                title: "ПОТРАЧЕНО",
                value: spentMoney,
                width: model.screenWidth),
          ])
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.title, required this.value, required this.width});

  final String title;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width * 0.3,
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.03,
                  color: Theme.of(context).colorScheme.outline)),
          Text(
            value,
          ),
        ],
      ),
    );
  }
}
