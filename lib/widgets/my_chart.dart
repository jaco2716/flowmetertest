import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/providers/select_type_provider.dart';

class MyChart extends StatefulWidget {
  final double flowValue;
  final double pressureValue;
  const MyChart({Key? key, required this.flowValue, required this.pressureValue}) : super(key: key);

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  double chartIndex = 0;
  List<double> minY = [0, 0];
  List<double> maxY = [0, 0];
  List<double> chartValue = [0, 0];
  // bool loading = false;

  List<Stream<List<int>>> streams = [];
  List<List<FlSpot>> chartValues = [[], []];
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff23b6e6),
  ];
  final List<Color> gradientColors2 = [
    const Color.fromARGB(255, 230, 129, 35),
    const Color.fromARGB(255, 230, 129, 35),
  ];

  @override
  Widget build(BuildContext context) {
    var selectTypeListProvider = Provider.of<SelectTypeListProvider>(context);
    chartValues[0].add(FlSpot(chartIndex, (widget.flowValue * 100).roundToDouble() / 100));
    chartValues[1].add(FlSpot(chartIndex, (widget.pressureValue * 100).roundToDouble() / 100));
    if (chartValues[0].length > 60) {
      chartValues[0].removeAt(0);
    }
    if (chartValues[1].length > 60) {
      chartValues[1].removeAt(0);
    }

    minY[selectTypeListProvider.indexSelected] =
        chartValues[selectTypeListProvider.indexSelected].reduce((curr, next) => curr.y < next.y ? curr : next).y;
    maxY[selectTypeListProvider.indexSelected] =
        chartValues[selectTypeListProvider.indexSelected].reduce((curr, next) => curr.y > next.y ? curr : next).y;
    chartIndex++;

    return Stack(
      children: [
        AspectRatio(
          // aspectRatio: 0.8,
          aspectRatio: 1,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              // color: Color(0xff232d37),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 6.0, top: 8, bottom: 8),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: calculateInterval(maxY[selectTypeListProvider.indexSelected], minY[selectTypeListProvider.indexSelected]),
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xff37434d),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: const Color(0xff37434d),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text(
                        'Time',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      axisNameSize: 30,
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        // interval: (maxY.ceil() + 1) / 4,
                        interval: calculateInterval(maxY[selectTypeListProvider.indexSelected], minY[selectTypeListProvider.indexSelected]),
                        getTitlesWidget: leftTitleWidgets,
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                  minX: chartValues[selectTypeListProvider.indexSelected].first.x,
                  maxX: chartValues[selectTypeListProvider.indexSelected].first.x + 60, //60 secounds of data
                  // minY = min - difference from max to min divided by 10, with .5 margin
                  minY: minY[selectTypeListProvider.indexSelected] -
                      ((maxY[selectTypeListProvider.indexSelected] - minY[selectTypeListProvider.indexSelected]) / 10 + .5),
                  // minX = min + difference from max to min divided by 10, with .5 margin
                  maxY: maxY[selectTypeListProvider.indexSelected] +
                      ((maxY[selectTypeListProvider.indexSelected] - minY[selectTypeListProvider.indexSelected]) / 10 + .5),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartValues[selectTypeListProvider.indexSelected],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double calculateInterval(double maxY, double minY) {
    // return 10 * (80 / 100);
    double interval;
    // if (maxY == minY) return 1;
    if (maxY - minY < 1) {
      interval = 0.1;
    } else if (maxY - minY < 5) {
      interval = 0.5;
    } else if (maxY - minY < 20) {
      interval = 1;
    } else if (maxY - minY < 50) {
      interval = 5;
    } else {
      interval = (5 * ((maxY - minY) / 50).round()).toDouble();
    }
    return interval;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    String text = value.toStringAsFixed(1);
    String intText = value.toInt().toString();
    var remain = value - value.floor();
    if (remain > 0) {
      return Text(
        '$text →',
        style: const TextStyle(fontSize: 10, color: Colors.white30),
      );
    }
    return Text(intText, style: style, textAlign: TextAlign.left);
  }
}
