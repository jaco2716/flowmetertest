// import 'dart:typed_data';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flowprotest/model/providers/select_type_provider.dart';
// import 'package:flowprotest/widgets/my_scrollview_w_constraints.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SingleChartPage extends StatefulWidget {
//   final Stream<List<List<int>>> combinedStreams;

//   const SingleChartPage({Key? key, required this.combinedStreams}) : super(key: key);

//   @override
//   State<SingleChartPage> createState() => _SingleChartPageState();
// }

// class _SingleChartPageState extends State<SingleChartPage> {
//   double chartIndex = 0;
//   List<double> minY = [0, 0];
//   List<double> maxY = [0, 0];
//   List<double> chartValue = [0, 0];
//   // bool loading = false;

//   List<Stream<List<int>>> streams = [];
//   List<List<FlSpot>> chartValues = [[], []];
//   final List<Color> gradientColors = [
//     const Color(0xff23b6e6),
//     const Color(0xff23b6e6),
//   ];
//   final List<Color> gradientColors2 = [
//     const Color.fromARGB(255, 230, 129, 35),
//     const Color.fromARGB(255, 230, 129, 35),
//   ];

//   @override
//   void initState() {
//     // TODO: implement initState
//     // streams = [
//     //   widget.flowCharacteristic.value.asBroadcastStream(),
//     //   widget.pressureCharacteristic.value.asBroadcastStream(),
//     // ];
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: const Text('Chart')),
//         body: ChangeNotifierProvider(
//           create: (context) => SelectTypeListProvider([
//             SelectType(0, 'Flow'),
//             SelectType(1, 'Pressure'),
//           ]),
//           builder: (context, child) {
//             var selectTypeListProvider = Provider.of<SelectTypeListProvider>(context);

//             return MyScrollviewWConstraints(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 // crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Container(
//                       decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue),
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       // width: double.infinity,
//                       child: DropdownButton<SelectType>(
//                         value: selectTypeListProvider.selectType[selectTypeListProvider.indexSelected],
//                         icon: const Icon(Icons.arrow_drop_down),
//                         elevation: 16,
//                         dropdownColor: Colors.blue,
//                         borderRadius: BorderRadius.circular(5),
//                         isExpanded: true,

//                         // style: const TextStyle(color: Colors.),
//                         underline: const SizedBox.shrink(),
//                         onChanged: (SelectType? newValue) {
//                           if (newValue != null) {
//                             // loading = true;

//                             context.read<SelectTypeListProvider>().changeSelected(newValue.id);
//                             // maxY = 0;
//                             // minY = 0;
//                             // dataindex = 0;
//                             // dataValues = [];
//                             // loading = false;
//                             // Future.delayed(const Duration(milliseconds: 100), () {
//                             // });
//                           }
//                         },
//                         items: selectTypeListProvider.selectType.map<DropdownMenuItem<SelectType>>((SelectType value) {
//                           return DropdownMenuItem<SelectType>(
//                             value: value,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SizedBox(child: Text(value.title)),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       color: Colors.black45,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         SizedBox(height: 50, child: ElevatedButton(onPressed: () {}, child: const Text('   Now   '))),
//                         TextButton(onPressed: () {}, child: const Text('5 hours')),
//                         TextButton(onPressed: () {}, child: const Text('1 Month')),
//                         TextButton(onPressed: () {}, child: const Text('   All   ')),
//                       ],
//                     ),
//                   ),
//                   StreamBuilder<List<List<int>>>(
//                       // initialData: [0, 0, 0, 0],
//                       // stream: widget.services[2].characteristics.firstWhere((element) => element.uuid == '3300c0b5-2369-4322-8296-5564f44850b3').value,
//                       // stream: streams[selectTypeListProvider.indexSelected],
//                       stream: widget.combinedStreams,
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           // return Text('${snapshot.data}');
//                           if (snapshot.data?[0].length != 4 || snapshot.data?[1].length != 4 || snapshot.data?[2].length != 4) {
//                             return const SizedBox(height: 150, width: 150, child: Center(child: CircularProgressIndicator()));
//                             // return const SizedBox(height: 250, width: 250, child: Center(child: Text('No data')));
//                           }
//                           var pressureBytes = Uint8List.fromList(snapshot.data![0]);
//                           var pressureValue = ByteData.view(pressureBytes.buffer).getInt32(0, Endian.little);
//                           var barometerBytes = Uint8List.fromList(snapshot.data![1]);
//                           var barometerValue = ByteData.view(barometerBytes.buffer).getInt32(0, Endian.little);
//                           var flowBytes = Uint8List.fromList(snapshot.data![2]);
//                           var flowValue = ByteData.view(flowBytes.buffer).getInt32(0, Endian.little);

//                           // if (selectTypeListProvider.indexSelected == 0) {
//                           //   // if (selectTypeListProvider.indexSelected == 0) {
//                           //   //TODO get right multiplier
//                           //   // var flowMultiplier = ((0 + 14.7) / 14.7) * ((200 + 460) / (80.4 + 460)) * 0.06;
//                           //   // // var flowMultiplier = ((80.46 + 460) / 530 * 14.7 / (14.7 + 40));
//                           //   // print(flowMultiplier);
//                           //   // dataValue = numberValue * flowMultiplier;
//                           // } else {
//                           // }
//                           chartValue[0] = ((flowValue.toDouble() * (1545 / (pressureValue * 0.00002952998015649)) * (80 + 460)) / (144 * 24.7)) / 60;
//                           // dataValue[0] = (flowValue.toDouble() * 1545 * (200 + 460)) / ((pressureValue * 0.00002952998015649) * 144 * 24.7);
//                           // dataValue[0] = flowValue.toDouble() / 10;
//                           chartValue[1] = ((pressureValue - barometerValue).toDouble() * 0.00040146303904694);
//                           chartValues[0].add(FlSpot(chartIndex, chartValue[0]));
//                           chartValues[1].add(FlSpot(chartIndex, chartValue[1]));
//                           if (chartValues[0].length > 60) {
//                             chartValues[0].removeAt(0);
//                           }
//                           if (chartValues[1].length > 60) {
//                             chartValues[1].removeAt(0);
//                           }

//                           minY[selectTypeListProvider.indexSelected] =
//                               chartValues[selectTypeListProvider.indexSelected].reduce((curr, next) => curr.y < next.y ? curr : next).y;
//                           maxY[selectTypeListProvider.indexSelected] =
//                               chartValues[selectTypeListProvider.indexSelected].reduce((curr, next) => curr.y > next.y ? curr : next).y;
//                           // print('max: $maxY');
//                           // print('min: $minY');

//                           // if (minY > finalDouble || dataindex < 1) {
//                           //   minY = finalDouble;
//                           // }
//                           // if (maxY < finalDouble) {
//                           //   // maxY = finalDouble;
//                           // }

//                           chartIndex++;
//                           return Column(
//                             children: [
//                               const SizedBox(height: 20),
//                               Text(
//                                 chartValue[selectTypeListProvider.indexSelected].toStringAsFixed(2),
//                                 style: const TextStyle(fontSize: 25, color: Color(0xff23b6e6)),
//                               ),
//                               AspectRatio(
//                                 // aspectRatio: 0.8,
//                                 aspectRatio: 1,
//                                 child: Container(
//                                   decoration: const BoxDecoration(
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(18),
//                                     ),
//                                     // color: Color(0xff232d37),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(right: 4.0, left: 6.0, top: 8, bottom: 8),
//                                     child: LineChart(
//                                       LineChartData(
//                                         gridData: FlGridData(
//                                           show: true,
//                                           drawVerticalLine: true,
//                                           horizontalInterval: calculateInterval(
//                                               maxY[selectTypeListProvider.indexSelected], minY[selectTypeListProvider.indexSelected]),
//                                           verticalInterval: 1,
//                                           getDrawingHorizontalLine: (value) {
//                                             return FlLine(
//                                               color: const Color(0xff37434d),
//                                               strokeWidth: 1,
//                                             );
//                                           },
//                                           getDrawingVerticalLine: (value) {
//                                             return FlLine(
//                                               color: const Color(0xff37434d),
//                                               strokeWidth: 1,
//                                             );
//                                           },
//                                         ),
//                                         titlesData: FlTitlesData(
//                                           show: true,
//                                           rightTitles: AxisTitles(
//                                             sideTitles: SideTitles(showTitles: false),
//                                           ),
//                                           topTitles: AxisTitles(
//                                             sideTitles: SideTitles(showTitles: false),
//                                           ),
//                                           bottomTitles: AxisTitles(
//                                             axisNameWidget: const Text(
//                                               'Time',
//                                               style: TextStyle(color: Colors.white54, fontSize: 16),
//                                             ),
//                                             axisNameSize: 30,
//                                           ),
//                                           leftTitles: AxisTitles(
//                                             sideTitles: SideTitles(
//                                               showTitles: true,
//                                               // interval: (maxY.ceil() + 1) / 4,
//                                               interval: calculateInterval(
//                                                   maxY[selectTypeListProvider.indexSelected], minY[selectTypeListProvider.indexSelected]),
//                                               getTitlesWidget: leftTitleWidgets,
//                                               reservedSize: 42,
//                                             ),
//                                           ),
//                                         ),
//                                         borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
//                                         minX: chartValues[selectTypeListProvider.indexSelected].first.x,
//                                         maxX: chartValues[selectTypeListProvider.indexSelected].first.x + 60, //60 secounds of data
//                                         // minY = min - difference from max to min divided by 10, with .5 margin
//                                         minY: minY[selectTypeListProvider.indexSelected] -
//                                             ((maxY[selectTypeListProvider.indexSelected] - minY[selectTypeListProvider.indexSelected]) / 10 + .5),
//                                         // minX = min + difference from max to min divided by 10, with .5 margin
//                                         maxY: maxY[selectTypeListProvider.indexSelected] +
//                                             ((maxY[selectTypeListProvider.indexSelected] - minY[selectTypeListProvider.indexSelected]) / 10 + .5),
//                                         lineBarsData: [
//                                           LineChartBarData(
//                                             spots: chartValues[selectTypeListProvider.indexSelected],
//                                             isCurved: true,
//                                             gradient: LinearGradient(
//                                               colors: gradientColors,
//                                               begin: Alignment.centerLeft,
//                                               end: Alignment.centerRight,
//                                             ),
//                                             barWidth: 2,
//                                             isStrokeCapRound: true,
//                                             dotData: FlDotData(show: false),
//                                             belowBarData: BarAreaData(
//                                               show: true,
//                                               gradient: LinearGradient(
//                                                 colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
//                                                 begin: Alignment.centerLeft,
//                                                 end: Alignment.centerRight,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         } else if (snapshot.hasError) {
//                           // TODO: do something with the error
//                           return Text(snapshot.error.toString());
//                         }
//                         // TODO: the data is not ready, show a loading indicator
//                         return const Center(child: CircularProgressIndicator());
//                       }),
//                   const SizedBox(height: 30),
//                   ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.save), label: const Text('Save as Excell')),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             );
//           },
//         ));
//   }

//   // Widget bottomTitleWidgets(double value, TitleMeta meta) {
//   //   const style = TextStyle(
//   //     color: Color(0xff68737d),
//   //     fontWeight: FontWeight.bold,
//   //     fontSize: 16,
//   //   );
//   //   Widget text;
//   //   switch (value.toInt()) {
//   //     case 20:
//   //       text = const Text('10', style: style);
//   //       break;
//   //     case 40:
//   //       text = const Text('30', style: style);
//   //       break;
//   //     case 60:
//   //       text = const Text('60', style: style);
//   //       break;
//   //     case 80:
//   //       text = const Text('80', style: style);
//   //       break;
//   //     default:
//   //       text = const Text('', style: style);
//   //       break;
//   //   }

//   //   return SideTitleWidget(
//   //     axisSide: meta.axisSide,
//   //     space: 8.0,
//   //     child: text,
//   //   );
//   // }

//   double calculateInterval(double maxY, double minY) {
//     // return 10 * (80 / 100);
//     double interval;
//     // if (maxY == minY) return 1;
//     if (maxY - minY < 1) {
//       interval = 0.1;
//     } else if (maxY - minY < 5) {
//       interval = 0.5;
//     } else if (maxY - minY < 20) {
//       interval = 1;
//     } else if (maxY - minY < 50) {
//       interval = 5;
//     } else {
//       interval = (5 * ((maxY - minY) / 50).round()).toDouble();
//     }
//     return interval;
//   }

//   Widget leftTitleWidgets(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: Color(0xff67727d),
//       fontWeight: FontWeight.bold,
//       fontSize: 16,
//     );
//     String text = value.toStringAsFixed(1);
//     String intText = value.toInt().toString();
//     var remain = value - value.floor();
//     if (remain > 0) {
//       return Text(
//         '$text →',
//         style: const TextStyle(fontSize: 10, color: Colors.white30),
//       );
//     }
//     return Text(intText, style: style, textAlign: TextAlign.left);
//   }
// }
