import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rewild/domain/entities/advert_stat.dart';

class Chart extends StatelessWidget {
  final List<AdvertStatModel> data;

  const Chart({super.key, required this.data, this.clicks = false});
  final bool clicks;

  bool dateInList(DateTime date, List<DateTime> list) {
    return list.any((element) =>
        element.day == date.day &&
        element.month == date.month &&
        element.year == date.year &&
        element.hour == date.hour &&
        element.minute == date.minute);
  }

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

        spots.add(FlSpot(data[i].createdAt.millisecondsSinceEpoch.toDouble(),
            clicksDiff.toDouble()));
        continue;
      }
      int viewsDiff = data[i].views - data[i - 1].views;
      spots.add(FlSpot(data[i].createdAt.millisecondsSinceEpoch.toDouble(),
          viewsDiff.toDouble()));
    }

    // final times = data.map((e) => e.createdAt).toList();
    final n = spots.length < 9 ? 1 : 3;
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
                      interval: n * 1000 * 60 * 60,
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        DateTime createdAt =
                            DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        String formattedTime =
                            '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
                        return RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.02),
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
              isCurved: false,
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
          lineTouchData: LineTouchData(
              enabled: true,
              // touchCallback:
              //     (FlTouchEvent event, LineTouchResponse? touchResponse) {
              //   // TODO : Utilize touch event here to perform any operation
              // },
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Theme.of(context).colorScheme.surfaceVariant,
                tooltipRoundedRadius: 20.0,
                showOnTopOfTheChartBoxArea: true,
                fitInsideHorizontally: true,
                tooltipMargin: 0,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map(
                    (LineBarSpot touchedSpot) {
                      String tooltipText = "";
                      final index = touchedSpot.spotIndex;

                      if (index > 0) {
                        final prevTime = spots[index - 1].x;
                        final timeDif =
                            (spots[index].x - prevTime.toInt()) / 60000;

                        if (timeDif > 1) {
                          tooltipText = " за ${timeDif.toStringAsFixed(0)} мин";
                        }
                      }

                      final textStyle = TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      );
                      return LineTooltipItem(
                          spots[touchedSpot.spotIndex].y.toStringAsFixed(0),
                          textStyle,
                          children: [
                            TextSpan(
                                text: tooltipText,
                                style: const TextStyle(
                                  fontSize: 7,
                                ))
                          ]);
                    },
                  ).toList();
                },
              ),
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> indicators) {
                return indicators.map(
                  (int index) {
                    final line = FlLine(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        strokeWidth: 1,
                        dashArray: [2, 4]);
                    return TouchedSpotIndicatorData(
                      line,
                      const FlDotData(show: false),
                    );
                  },
                ).toList();
              },
              getTouchLineEnd: (_, __) => double.infinity),
        )),
      ),
    );
  }
}
