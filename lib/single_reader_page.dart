import 'dart:math';
import 'dart:typed_data';
import 'package:flowprotest/data_testing_page.dart';
import 'package:flowprotest/widgets/my_chart.dart';
import 'package:flowprotest/widgets/my_scrollview_w_constraints.dart';
import 'package:flowprotest/single_chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'model/providers/select_type_provider.dart';
import 'widgets/my_dropdown_button.dart';

class SingleReaderPage extends StatefulWidget {
  final List<BluetoothService> services;

  final String title;
  const SingleReaderPage({Key? key, required this.title, required this.services}) : super(key: key);

  @override
  State<SingleReaderPage> createState() => _SingleReaderPageState();
}

class _SingleReaderPageState extends State<SingleReaderPage> {
  // bool isOn = true;
  BluetoothService? dataService;
  BluetoothService? timeService;
  BluetoothCharacteristic? pressureCharacteristic;
  BluetoothCharacteristic? barometerCharacteristic;
  BluetoothCharacteristic? flowCharacteristic;
  BluetoothCharacteristic? temperatureCharacteristic;
  BluetoothCharacteristic? timeCharacteristic;
  List<List<int>> dateData = [];
  bool isNotifying = true;

  void setupService() async {
    print('Setup!!!');
    //Time setup
    int timeServiceIndex = widget.services.indexWhere((element) => element.uuid.toString() == '00001805-0000-1000-8000-00805f9b34fb');
    if (timeServiceIndex != -1) timeService = widget.services[timeServiceIndex];
    int timeIndex = timeService?.characteristics.indexWhere((element) => element.uuid.toString() == '00002a2b-0000-1000-8000-00805f9b34fb') ?? -1;
    if (timeIndex != -1) timeCharacteristic = timeService?.characteristics[timeIndex];

    //Service setup
    int serviceIndex = widget.services.indexWhere((element) => element.uuid.toString() == '8d8cceb9-ec48-4621-b293-0bafb0e0fa2d');
    if (serviceIndex != -1) dataService = widget.services[serviceIndex];
    int pressureIndex = dataService?.characteristics.indexWhere((element) => element.uuid.toString() == '3300c0b5-2369-4322-8296-5564f44850b3') ?? -1;
    if (pressureIndex != -1) pressureCharacteristic = dataService?.characteristics[pressureIndex];
    int barometerIndex =
        dataService?.characteristics.indexWhere((element) => element.uuid.toString() == 'c6ae9dac-5cfe-43cc-9c24-cbcf6e48e820') ?? -1;
    if (barometerIndex != -1) barometerCharacteristic = dataService?.characteristics[barometerIndex];
    // int flowIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '951770bd-a550-4466-b16f-4bc3170f4d0e');
    int flowIndex = dataService?.characteristics.indexWhere((element) => element.uuid.toString() == '7cb8e55f-d785-4c62-b6f7-ba6ba7581b7b') ?? -1;
    if (flowIndex != -1) flowCharacteristic = dataService?.characteristics[flowIndex];
    int temperatureIndex =
        dataService?.characteristics.indexWhere((element) => element.uuid.toString() == 'f3d4b10d-7485-4945-a849-162d8acc1f42') ?? -1;
    if (temperatureIndex != -1) temperatureCharacteristic = dataService?.characteristics[temperatureIndex];

    var timeValue = await timeCharacteristic?.read();
    if (timeValue != null) {
      var bytes = Uint8List.fromList(timeValue);
      var yearValue = ByteData.view(bytes.buffer).getInt16(0, Endian.little);
      DateTime deviceDate = DateTime(yearValue, bytes[2], bytes[3], bytes[4], bytes[5], bytes[6]);
      var dateNow = DateTime.now();
      if (dateNow.difference(deviceDate).inMinutes > 2) {
        await setDeviceTime();
      }
    }
    await timeCharacteristic?.setNotifyValue(isNotifying);
    await pressureCharacteristic?.setNotifyValue(isNotifying);
    await barometerCharacteristic?.setNotifyValue(isNotifying);
    await flowCharacteristic?.setNotifyValue(isNotifying);
    await temperatureCharacteristic?.setNotifyValue(isNotifying);
  }

  @override
  void initState() {
    setupService();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('new state!!!');
    // if (dateData.length > 4) {
    // int byteI = 18;
    // print('${dateData[0].sublist(1, 3)}- i=$byteI: ${dateData[0].sublist(byteI)}');
    // print('${dateData[1].sublist(1, 3)}- i=$byteI: ${dateData[1].sublist(byteI)}');
    // print('${dateData[2].sublist(1, 3)}- i=$byteI: ${dateData[2].sublist(byteI)}');
    // print('${dateData[3].sublist(1, 3)}- i=$byteI: ${dateData[3].sublist(byteI)}');
    // print('${dateData[4].sublist(1, 3)}- i=$byteI: ${dateData[4].sublist(byteI)}');
    // var testValue = [71, 39];
    // var testValue2 = [39, 69];
    // var testValue3 = [69, 39];
    // var testValue4 = [39, 73];
    // var testValue5 = [73, 39];

    // print('$testValue = ${ByteData.view(Uint8List.fromList(testValue).buffer).getInt16(0, Endian.little)}');
    // print('$testValue2 = ${ByteData.view(Uint8List.fromList(testValue2).buffer).getInt16(0, Endian.little)}');
    // print('$testValue3 = ${ByteData.view(Uint8List.fromList(testValue3).buffer).getInt16(0, Endian.little)}');
    // print('$testValue4 = ${ByteData.view(Uint8List.fromList(testValue4).buffer).getInt16(0, Endian.little)}');
    // print('$testValue5 = ${ByteData.view(Uint8List.fromList(testValue5).buffer).getInt16(0, Endian.little)}');

    // print(dateData[0][21]);
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         // Navigator.push(
        //         //     context,
        //         //     MaterialPageRoute(
        //         //         builder: (context) => SingleChartPage(
        //         //                 combinedStreams: CombineLatestStream.list([
        //         //               pressureCharacteristic!.value,
        //         //               barometerCharacteristic!.value,
        //         //               flowCharacteristic!.value,
        //         //             ]))));
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => DataTestingPage(
        //                     dataService: dataService!,
        //                     timeService: timeService!,
        //                     pressureCharacteristic: pressureCharacteristic!,
        //                     flowCharacteristic: flowCharacteristic!,
        //                     timeCharacteristic: timeCharacteristic!)));
        //       },
        //       icon: const Icon(Icons.line_style))
        // ],
      ),
      body: ChangeNotifierProvider(
          create: (context) => SelectTypeListProvider([
                SelectType(0, 'Gas Flow - CFH'),
                SelectType(1, 'Pressure - PSI'),
              ]),
          child:
              // builder: (context, child) {
              //   var selectTypeListProvider = Provider.of<SelectTypeListProvider>(context);

              //   return
              MyScrollviewWConstraints(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ElevatedButton(
                //     onPressed: () {
                //       selectTypeListProvider.updatetest();
                //     },
                //     child: Text('s')),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder<List<List<int>>>(
                      // stream: pressureCharacteristic?.value,
                      stream: CombineLatestStream.list([
                        timeCharacteristic!.value,
                        pressureCharacteristic!.value,
                        barometerCharacteristic!.value,
                        flowCharacteristic!.value,
                        temperatureCharacteristic!.value,
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data?[0].length != 10 ||
                              snapshot.data?[1].length != 4 ||
                              snapshot.data?[2].length != 4 ||
                              snapshot.data?[3].length != 4 ||
                              snapshot.data?[4].length != 2) {
                            print(snapshot.data?[0].length);
                            print(snapshot.data?[1].length);
                            print(snapshot.data?[2].length);
                            print(snapshot.data?[3].length);
                            print(snapshot.data?[4].length);

                            print('loading');
                            return const SizedBox(height: 150, width: 150, child: Center(child: CircularProgressIndicator()));
                            // return const SizedBox(height: 250, width: 250, child: Center(child: Text('No data')));
                          }
                          var timeBytes = Uint8List.fromList(snapshot.data![0]);
                          var yearValue = ByteData.view(timeBytes.buffer).getInt16(0, Endian.little);
                          DateTime date = DateTime(yearValue, timeBytes[2], timeBytes[3], timeBytes[4], timeBytes[5], timeBytes[6]);
                          var dfTime = DateFormat('HH:mm');
                          var dfDate = DateFormat('dd/MM/yyyy');

                          var barometerBytes = Uint8List.fromList(snapshot.data![2]);
                          var barometerData = ByteData.view(barometerBytes.buffer).getInt32(0, Endian.little);
                          var barometerValue = ByteData.view(barometerBytes.buffer).getInt32(0, Endian.little) * 0.00002952998015649;
                          var pressureBytes = Uint8List.fromList(snapshot.data![1]);
                          var pressureData = ByteData.view(pressureBytes.buffer).getInt32(0, Endian.little);
                          var pressureValue = (pressureData - barometerData).toDouble() * 0.00040146303904694;
                          var temperatureBytes = Uint8List.fromList(snapshot.data![4]);
                          var temperatureValue = ByteData.view(temperatureBytes.buffer).getInt16(0, Endian.little);
                          var flowBytes = Uint8List.fromList(snapshot.data![3]);
                          var flowData = ByteData.view(flowBytes.buffer).getInt32(0, Endian.little);
                          // var flowValue = ((flowData * (1545 / 28.964) * ((((temperatureValue / 100) * 9 / 5) + 32) + 460)) /
                          //         (144 * (pressureData * 0.00002952998015649))) /
                          //     60;
                          var flowValue = flowData / 100;

                          // print('//bytes');
                          // print(pressureBytes);
                          // print(barometerBytes);
                          // print(flowBytes);
                          // print(numberValue);
                          //1012376
                          //1084960
                          //TODO udregning
                          // numbervalue - BarometerValue * in/H20
                          //TODO !!! Flow bliver udreget ved hjælp af temperatur og pressure??
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        dfTime.format(date),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        dfDate.format(date),
                                        style: const TextStyle(fontSize: 11, color: Colors.white60),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.menu, color: Colors.grey),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${(((temperatureValue / 100) * 9 / 5) + 32).toStringAsFixed(2)}°',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        'Farenheit',
                                        style: TextStyle(fontSize: 11, color: Colors.white60),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              // MyDropdownButton(selectTypeListProvider: selectTypeListProvider),
                              MyDropdownButton(selectTypeListProvider: context.read<SelectTypeListProvider>()),
                              const SizedBox(height: 20),
                              Consumer<SelectTypeListProvider>(
                                builder: (context, value, child) {
                                  if (value.indexSelected == 0) {
                                    return DetailGaugeDial(
                                      value: flowValue,
                                      isPressure: false,
                                      title: 'Flow',
                                      messureUnit: 'CFH',
                                    );
                                  } else {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        DetailGaugeDial(
                                          value: pressureValue,
                                          // value: (((pressureValue - barometerValue).toDouble() * 0.00040146303904694)),
                                          isPressure: true,
                                          title: 'Pressure',
                                          messureUnit: 'inH2O',
                                        ),
                                        const SizedBox(width: 20),
                                        DetailGaugeDial(
                                          value: barometerValue,
                                          isPressure: true,
                                          title: 'Barometer',
                                          messureUnit: 'inHg',
                                          start2: 25,
                                          start3: 35,
                                          end: 60,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const Divider(),
                              MyChart(flowValue: flowValue, pressureValue: pressureValue),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          // TODO: do something with the error
                          return SizedBox(height: 250, width: 250, child: Text(snapshot.error.toString()));
                        }
                        // TODO: the data is not ready, show a loading indicator
                        return const SizedBox(height: 250, width: 250, child: Center(child: CircularProgressIndicator()));
                      }),
                ),
                // ElevatedButton(
                //     onPressed: () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => DataTestingPage(
                //                   dataService: dataService!,
                //                   timeService: timeService!,
                //                   pressureCharacteristic: pressureCharacteristic!,
                //                   flowCharacteristic: flowCharacteristic!,
                //                   timeCharacteristic: timeCharacteristic!)));
                //     },
                //     child: const Text('   Data Testing   ')),
              ],
            ),
          )),
    );
  }

  Future<void> setDeviceTime() async {
    try {
      DateTime timeNow = DateTime.now();
      var yearByte = Uint8List(2)..buffer.asInt16List()[0] = timeNow.year;
      List<int> timeNowBytes = [];
      timeNowBytes.addAll(yearByte);
      timeNowBytes.addAll([timeNow.month, timeNow.day, timeNow.hour, timeNow.minute, timeNow.second, 7, 0, 0]);
      await timeCharacteristic?.write(timeNowBytes);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  changeNotifying(bool notify) async {
    await timeCharacteristic?.setNotifyValue(notify);
    await pressureCharacteristic?.setNotifyValue(notify);
    await flowCharacteristic?.setNotifyValue(notify);
  }
}

class DetailGaugeDial extends StatelessWidget {
  final double value;
  final bool isPressure;
  final String title;
  final String messureUnit;
  final double start1, start2, start3, end;
  const DetailGaugeDial({
    Key? key,
    required this.value,
    required this.isPressure,
    required this.title,
    required this.messureUnit,
    this.start1 = 0,
    this.start2 = 40,
    this.start3 = 60,
    this.end = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color1, color2, color3;

    if (isPressure) {
      color1 = Colors.white;
      color2 = Colors.green;
      color3 = Colors.blue;
    } else {
      color1 = Colors.green;
      color2 = Colors.orange;
      color3 = Colors.red;
    }
    return SizedBox(
      height: 165,
      width: 140,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GaugeAnootation(valueRange: end),
              TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0.0, end: value),
                  builder: (context, double tweenValue, child) {
                    return RadialGauge(
                      axes: [
                        RadialGaugeAxis(
                          minValue: start1,
                          maxValue: end,
                          minAngle: -140,
                          maxAngle: 140,
                          radius: 0.9,
                          width: 0.17,
                          color: Colors.transparent,
                          pointers: [
                            RadialNeedlePointer(
                                value: tweenValue,
                                thicknessStart: 16,
                                thicknessEnd: 0,
                                length: 0.85,
                                knobRadiusAbsolute: 8,
                                color: Colors.white,
                                knobColor: Colors.white)
                          ],
                          ticks: [
                            RadialTicks(interval: 10, alignment: RadialTickAxisAlignment.inside, color: Colors.white, length: 0.22, children: [
                              RadialTicks(
                                // interval: 50,
                                ticksInBetween: 5,
                                length: 0.2,
                                color: Colors.grey,
                              ),
                            ]),
                          ],
                          segments: [
                            RadialGaugeSegment(
                              minValue: start1,
                              maxValue: start2,
                              minAngle: -110,
                              maxAngle: -50,
                              color: color1,
                            ),
                            RadialGaugeSegment(
                              minValue: start2,
                              maxValue: start3,
                              minAngle: -50,
                              maxAngle: 50,
                              color: color2,
                            ),
                            RadialGaugeSegment(
                              minValue: start3,
                              maxValue: end,
                              minAngle: 50,
                              maxAngle: 140,
                              color: color3,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      messureUnit,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                        width: 60,
                        height: 22,
                        child: FittedBox(
                          child: Text(
                            value.toStringAsFixed(2),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // child: Text('820.88', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    // Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );

    // return SfRadialGauge(
    //   axes: <RadialAxis>[
    //     RadialAxis(
    //       minimum: 0,
    //       maximum: 100,
    //       // showLabels: false,
    //       ranges: <GaugeRange>[
    //         GaugeRange(startValue: start1, endValue: start2, color: color1),
    //         GaugeRange(startValue: start2, endValue: start3, color: color2),
    //         GaugeRange(startValue: start3, endValue: end, color: color3)
    //       ],
    //       pointers: <GaugePointer>[
    //         NeedlePointer(
    //           // knobStyle: const KnobStyle(knobRadius: 0.1, borderWidth: 20),
    //           // tailStyle: const TailStyle(width: 2, length: 0.2),
    //           // needleLength: 0.9,
    //           // needleStartWidth: 2,
    //           // needleEndWidth: 3,
    //           animationDuration: 1000,
    //           animationType: AnimationType.ease,
    //           enableAnimation: true,
    //           value: value,
    //         )
    //       ],
    //       annotations: <GaugeAnnotation>[
    //         GaugeAnnotation(
    //           widget: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Text('${value.round()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    //               Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
    //             ],
    //           ),
    //           angle: 90,
    //           positionFactor: 0.6,
    //         )
    //       ],
    //     )
    //   ],
    // );
  }
}

class GaugeAnootation extends StatelessWidget {
  final double valueRange;
  final double interval;
  GaugeAnootation({Key? key, required this.valueRange, this.interval = 10}) : super(key: key);

  double radius = 50.0;

  List<Widget> list() {
    List<int> data = [];
    // double currentAngle = pi * 0.361 * 2;
    double currentAngle = pi * (230 / 100 / pi);
    double angleDiff = (currentAngle + pi * 0.81) / (valueRange / interval);

    for (var i = 0; i < (valueRange / interval) + 1; i++) {
      data.add(i);
    }
    return data.map((int index) {
      final x = cos(currentAngle) * radius;
      final y = sin(currentAngle) * radius;
      currentAngle += angleDiff;
      return _radialListItem(x, y, index);
    }).toList();
  }

  Widget _radialListItem(double x, double y, int index) {
    return Center(
      child: Transform(
          transform: Matrix4.translationValues(x, y, 0.0),
          child: InkWell(
            onTap: () {
              print(index.toString());
            },
            child: Text(
              '${index * 10}',
              style: TextStyle(fontSize: 8, color: Colors.grey),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: list(),
    );
  }
}
