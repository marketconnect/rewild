import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rewild/domain/entities/auto_stat.dart';

class Chart extends StatelessWidget {
  final List<AutoStatModel> data;

  const Chart({super.key, required this.data, this.clicks = false});
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
        // int viewsDiff = data[i].views - data[i - 1].views;
        // final ctr = viewsDiff == 0 ? 0 : (clicksDiff / viewsDiff) * 100;
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
                      final textStyle = TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      );
                      return LineTooltipItem(
                        spots[touchedSpot.spotIndex].y.toStringAsFixed(2),
                        textStyle,
                      );
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
