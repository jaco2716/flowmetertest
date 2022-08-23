import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flowprotest/model/providers/select_type_provider.dart';
import 'package:flowprotest/my_scrollview_w_constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

class SingleChartPage extends StatefulWidget {
  final BluetoothCharacteristic pressureCharacteristic;
  final BluetoothCharacteristic flowCharacteristic;

  const SingleChartPage({Key? key, required this.pressureCharacteristic, required this.flowCharacteristic}) : super(key: key);

  @override
  State<SingleChartPage> createState() => _SingleChartPageState();
}

class _SingleChartPageState extends State<SingleChartPage> {
  int dataindex = 0;
  double minY = 0;
  double maxY = 0;
  double dataValue = 0;
  bool loading = false;

  List<Stream<List<int>>> streams = [];
  List<FlSpot> dataValues = [];
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff23b6e6),
  ];
  final List<Color> gradientColors2 = [
    const Color.fromARGB(255, 230, 129, 35),
    const Color.fromARGB(255, 230, 129, 35),
  ];

  @override
  void initState() {
    // TODO: implement initState
    streams = [
      widget.flowCharacteristic.value.asBroadcastStream(),
      widget.pressureCharacteristic.value.asBroadcastStream(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Chart')),
        body: ChangeNotifierProvider(
          create: (context) => SelectTypeListProvider([
            SelectType(0, 'Flow'),
            SelectType(1, 'Pressure'),
          ]),
          builder: (context, child) {
            var selectTypeListProvider = Provider.of<SelectTypeListProvider>(context);

            return MyScrollviewWConstraints(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<SelectType>(
                    value: selectTypeListProvider.selectType[selectTypeListProvider.indexSelected],
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    // style: const TextStyle(color: Colors.),
                    // underline: Container(
                    //   height: 2,
                    //   color: Colors.deepPurpleAccent,
                    // ),
                    onChanged: (SelectType? newValue) {
                      if (newValue != null) {
                        loading = true;

                        context.read<SelectTypeListProvider>().changeSelected(newValue.id);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          maxY = 0;
                          minY = 0;
                          dataindex = 0;
                          dataValues = [];
                          loading = false;
                        });
                      }
                    },
                    items: selectTypeListProvider.selectType.map<DropdownMenuItem<SelectType>>((SelectType value) {
                      return DropdownMenuItem<SelectType>(
                        value: value,
                        child: SizedBox(width: 200, child: Text(value.title)),
                      );
                    }).toList(),
                  ),
                  Container(
                    color: Colors.black45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(onPressed: () {}, child: const Text('1 Month')),
                        ElevatedButton(onPressed: () {}, child: const Text('1 Year')),
                        TextButton(onPressed: () {}, child: const Text('5 Years')),
                        TextButton(onPressed: () {}, child: const Text('All')),
                      ],
                    ),
                  ),
                  StreamBuilder<List<int>>(
                      // initialData: [0, 0, 0, 0],
                      // stream: widget.services[2].characteristics.firstWhere((element) => element.uuid == '3300c0b5-2369-4322-8296-5564f44850b3').value,
                      stream: streams[selectTypeListProvider.indexSelected],
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // return Text('${snapshot.data}');
                          if (snapshot.data?.length != 4) {
                            return const AspectRatio(
                              aspectRatio: 0.8,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          var bytes = Uint8List.fromList(snapshot.data!);
                          var numberValue = ByteData.view(bytes.buffer).getInt32(0, Endian.host);

                          if (context.read<SelectTypeListProvider>().indexSelected == 0) {
                            // if (selectTypeListProvider.indexSelected == 0) {
                            // dataValue = (numberValue).toDouble();
                            //TODO get right multiplier
                            var flowMultiplier = ((0 + 14.7) / 14.7) * ((200 + 460) / (80.4 + 460)) * 0.06;
                            // var flowMultiplier = ((80.46 + 460) / 530 * 14.7 / (14.7 + 40));
                            print(flowMultiplier);
                            dataValue = numberValue * flowMultiplier;
                          } else {
                            dataValue = (numberValue - 1009000) / 1000;
                          }
                          dataValues.add(FlSpot(dataindex.toDouble(), dataValue));
                          if (dataValues.length > 60) {
                            dataValues.removeAt(0);
                          }

                          minY = dataValues.reduce((curr, next) => curr.y < next.y ? curr : next).y;
                          maxY = dataValues.reduce((curr, next) => curr.y > next.y ? curr : next).y;
                          // print('max: $maxY');
                          // print('min: $minY');

                          // if (minY > finalDouble || dataindex < 1) {
                          //   minY = finalDouble;
                          // }
                          // if (maxY < finalDouble) {
                          //   // maxY = finalDouble;
                          // }

                          dataindex++;
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                loading ? '' : '$dataValue',
                                style: const TextStyle(fontSize: 25, color: Color(0xff23b6e6)),
                              ),
                              AspectRatio(
                                // aspectRatio: 0.8,
                                aspectRatio: 1,
                                child: loading
                                    ? const Center(child: CircularProgressIndicator())
                                    : Container(
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
                                                horizontalInterval: 1,
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
                                                    interval: calculateInterval(maxY, minY),
                                                    getTitlesWidget: leftTitleWidgets,
                                                    reservedSize: 42,
                                                  ),
                                                ),
                                              ),
                                              borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                                              minX: dataValues.first.x,
                                              maxX: dataValues.first.x + 60,
                                              minY: minY - ((maxY - minY) / 10 + .5),
                                              maxY: maxY + ((maxY - minY) / 10 + .5),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: dataValues,
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
                        } else if (snapshot.hasError) {
                          // TODO: do something with the error
                          return Text(snapshot.error.toString());
                        }
                        // TODO: the data is not ready, show a loading indicator
                        return const Center(child: CircularProgressIndicator());
                      }),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.save), label: const Text('Save as Excell')),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ));
  }

  // Widget bottomTitleWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     color: Color(0xff68737d),
  //     fontWeight: FontWeight.bold,
  //     fontSize: 16,
  //   );
  //   Widget text;
  //   switch (value.toInt()) {
  //     case 20:
  //       text = const Text('10', style: style);
  //       break;
  //     case 40:
  //       text = const Text('30', style: style);
  //       break;
  //     case 60:
  //       text = const Text('60', style: style);
  //       break;
  //     case 80:
  //       text = const Text('80', style: style);
  //       break;
  //     default:
  //       text = const Text('', style: style);
  //       break;
  //   }

  //   return SideTitleWidget(
  //     axisSide: meta.axisSide,
  //     space: 8.0,
  //     child: text,
  //   );
  // }

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
    print('interval: $interval');
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
