import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/app_colors.dart';
import 'package:rewild/domain/entities/auto_stat.dart';
import 'package:rewild/presentation/auto_stat_adv_screen/auto_stat_adv_view_model.dart';

class AutoStatAdvertScreen extends StatelessWidget {
  const AutoStatAdvertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutoStatViewModel>();
    final budget = model.budget;
    final isPursued = model.isPursued;
    final track = model.track;
    final untrack = model.untrack;
    final decoration = BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant),
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.surface);
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (isPursued) {
                await untrack();
                return;
              }
              await track();
            },
          ),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '₽$budget',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
          ))
          // ListView.builder(
          //     itemCount: autoStats.length,
          //     itemBuilder: (context, index) {
          //       return Container(
          //         decoration: const BoxDecoration(
          //           border: Border(
          //             bottom: BorderSide(
          //               color: Colors.grey,
          //               width: 0.5,
          //             ),
          //           ),
          //         ),
          //         child: Column(
          //           children: [
          //             Text(autoStats[index].clicks.toString()),
          //             Text(autoStats[index].cpc.toString()),
          //             Text(autoStats[index].ctr.toString()),
          //             Text(autoStats[index].spend.toString()),
          //             Text(autoStats[index].views.toString()),
          //             Text(autoStats[index].advertId.toString()),
          //             Text(autoStats[index].createdAt.toString()),
          //           ],
          //         ),
          //       );
          //     }),
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
        ),
        const _SecondRow()
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
    return Column(
      children: [
        Row(
          children: [
            _Chart(
              data: autoStatsList,
            ),
            _Chart(
              data: autoStatsList,
              clicks: true,
            ),
          ],
        ),
        Row(children: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.45,
            child: Text("Показы"),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.45,
            child: Text("Клики"),
          )
        ])
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  final List<AutoStatModel> data;

  _Chart({required this.data, this.clicks = false});
  final bool clicks;
  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      AppColors.contentColorCyan,
      AppColors.contentColorBlue,
    ];

    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      if (i == 0) {
        continue;
      }
      if (clicks) {
        double clicksDiff = data[i].clicks - data[i - 1].clicks;
        spots.add(FlSpot(data[i].createdAt.millisecondsSinceEpoch.toDouble(),
            clicksDiff.toDouble()));
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
                              style: TextStyle(fontSize: 5),
                            ));
                      })),
              topTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: false,
              )),
              rightTitles: AxisTitles(
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
            border: Border(
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
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: false),
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
