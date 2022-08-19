import 'dart:async';
import 'dart:typed_data';
import 'package:flowprotest/data_testing_page.dart';
import 'package:flowprotest/single_chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

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
  BluetoothCharacteristic? timeCharacteristic;
  List<List<int>> dateData = [];
  bool isNotifying = true;

  void setupService() async {
    //Barometer characteristic
    //c6ae9dac-5cfe-43cc-9c24-cbcf6e48e820
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
    int flowIndex = dataService?.characteristics.indexWhere((element) => element.uuid.toString() == '7cb8e55f-d785-4c62-b6f7-ba6ba7581b7b') ?? -1;
    // int flowIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '951770bd-a550-4466-b16f-4bc3170f4d0e');
    if (flowIndex != -1) flowCharacteristic = dataService?.characteristics[flowIndex];

    var timeValue = await timeCharacteristic?.read();
    if (timeValue != null) {
      var bytes = Uint8List.fromList(timeValue);
      var yearValue = ByteData.view(bytes.buffer).getInt16(0, Endian.little);
      DateTime deviceDate = DateTime(yearValue, bytes[2], bytes[3], bytes[4], bytes[5], bytes[6]);
      var dateNow = DateTime.now();
      if (dateNow.difference(deviceDate).inHours > 1) {
        setDeviceTime();
      }
    }
    await timeCharacteristic?.setNotifyValue(isNotifying);
    await pressureCharacteristic?.setNotifyValue(isNotifying);
    await barometerCharacteristic?.setNotifyValue(isNotifying);
    await flowCharacteristic?.setNotifyValue(isNotifying);
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SingleChartPage(
                            pressureCharacteristic: pressureCharacteristic!,
                            flowCharacteristic: flowCharacteristic!,
                          )));
            },
            icon: const Icon(Icons.bar_chart_rounded),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              StreamBuilder<List<int>>(
                stream: timeCharacteristic?.value,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?.isEmpty ?? true) {
                      return const Text('No data');
                    }
                    var bytes = Uint8List.fromList(snapshot.data!);
                    var yearValue = ByteData.view(bytes.buffer).getInt16(0, Endian.little);
                    DateTime date = DateTime(yearValue, bytes[2], bytes[3], bytes[4], bytes[5], bytes[6]);
                    var dfTime = DateFormat('HH:mm');
                    var dfDate = DateFormat('dd/MM/yyyy');
                    return Column(
                      children: [
                        Text(
                          dfTime.format(date),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dfDate.format(date),
                          style: const TextStyle(fontSize: 18, color: Colors.white60),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    // TODO: do something with the error
                    return Text(snapshot.error.toString());
                  }
                  // TODO: the data is not ready, show a loading indicator
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              // ElevatedButton(
              //   onPressed: () => setDeviceTime(),
              //   child: const Text('   Sync Time   '),
              // ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<List<List<int>>>(
                    // stream: pressureCharacteristic?.value,
                    stream: CombineLatestStream.list([
                      pressureCharacteristic!.value,
                      barometerCharacteristic!.value,
                      flowCharacteristic!.value,
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?[0].length != 4 || snapshot.data?[1].length != 4 || snapshot.data?[2].length != 4) {
                          return const SizedBox(height: 150, width: 150, child: Center(child: CircularProgressIndicator()));
                          // return const SizedBox(height: 250, width: 250, child: Center(child: Text('No data')));
                        }
                        var pressureBytes = Uint8List.fromList(snapshot.data![0]);
                        var pressureValue = ByteData.view(pressureBytes.buffer).getInt32(0, Endian.little);
                        var barometerBytes = Uint8List.fromList(snapshot.data![1]);
                        var barometerValue = ByteData.view(barometerBytes.buffer).getInt32(0, Endian.little);
                        var flowBytes = Uint8List.fromList(snapshot.data![2]);
                        var flowValue = ByteData.view(flowBytes.buffer).getInt32(0, Endian.little);

                        // print('//bytes');
                        // print(pressureBytes);
                        // print(barometerBytes);
                        // print(flowBytes);
                        // print(numberValue);
                        //1012376
                        //1084960
                        //TODO udregning
                        // numbervalue - BarometerValue * in/H20
                        //TODO !!! Flow bliver udreget ved hjælp af temperatur og pressure
                        return Column(
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              // child: DetailGaugeDial(value: ((numberValue.toDouble())), isPressure: true),
                              child: DetailGaugeDial(value: (((pressureValue - barometerValue).toDouble() * 0.00040146303904694)), isPressure: true),
                            ),
                            const Text('Pressure'),
                            const Divider(),
                            SizedBox(
                              height: 150,
                              width: 150,
                              // child: DetailGaugeDial(value: ((numberValue.toDouble())), isPressure: true),
                              child: DetailGaugeDial(value: ((barometerValue.toDouble() * 0.00002952998015649)), isPressure: true),
                            ),
                            const Text('Barometer'),
                            const Divider(),
                            SizedBox(
                              height: 150,
                              width: 150,
                              // child: DetailGaugeDial(value: ((numberValue.toDouble())), isPressure: true),
                              child: DetailGaugeDial(value: ((flowValue.toDouble())), isPressure: false),
                            ),
                            const Text('Flow'),
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
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: StreamBuilder<List<int>>(
              //       stream: barometerCharacteristic?.value,
              //       builder: (context, snapshot) {
              //         if (snapshot.hasData) {
              //           if (snapshot.data?.length != 4) {
              //             return const SizedBox(height: 150, width: 150, child: Center(child: CircularProgressIndicator()));
              //             // return const SizedBox(height: 250, width: 250, child: Center(child: Text('No data')));
              //           }
              //           var bytes = Uint8List.fromList(snapshot.data!);
              //           var numberValue = ByteData.view(bytes.buffer).getInt32(0, Endian.little);
              //           // print(numberValue);
              //           //1012376
              //           //1084960

              //           return Column(
              //             children: [
              //               SizedBox(
              //                 height: 150,
              //                 width: 150,
              //                 // child: DetailGaugeDial(value: ((numberValue.toDouble())), isPressure: true),
              //                 child: DetailGaugeDial(value: ((numberValue.toDouble() * 0.00002952998015649)), isPressure: true),
              //               ),
              //               const Text('Barometer'),
              //             ],
              //           );
              //         } else if (snapshot.hasError) {
              //           // TODO: do something with the error
              //           return SizedBox(height: 150, width: 150, child: Text(snapshot.error.toString()));
              //         }
              //         // TODO: the data is not ready, show a loading indicator
              //         return const SizedBox(height: 150, width: 150, child: Center(child: CircularProgressIndicator()));
              //       }),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: StreamBuilder<List<int>>(
              //       stream: flowCharacteristic?.value,
              //       builder: (context, snapshot) {
              //         if (snapshot.hasData) {
              //           // return Text('${snapshot.data}');
              //           if (snapshot.data?.length != 4) {
              //             return const SizedBox(height: 150, width: 150, child: Center(child: CircularProgressIndicator()));
              //             // return const SizedBox(height: 250, width: 250, child: Center(child: Text('No data')));
              //           }
              //           var bytes = Uint8List.fromList(snapshot.data!);
              //           var numberValue = ByteData.view(bytes.buffer).getInt32(0, Endian.little);
              //           print(bytes);

              //           // TODO: do something with the data
              //           return Column(
              //             children: [
              //               SizedBox(
              //                   height: 150,
              //                   width: 150,
              //                   child: DetailGaugeDial(value: (((numberValue.toDouble() / 1000 * 70))), isPressure: false)),
              //               Text('$bytes'),
              //               Text('$numberValue'),
              //             ],
              //           );
              //           // return SizedBox(height: 250, child: DetailGaugeDial(value: (((numberValue.toDouble() / 10000 - 16))), isPressure: false));
              //         } else if (snapshot.hasError) {
              //           // TODO: do something with the error
              //           return SizedBox(height: 150, width: 150, child: Text(snapshot.error.toString()));
              //         }
              //         // TODO: the data is not ready, show a loading indicator
              //         return const SizedBox(height: 150, width: 150, child: Center(child: CircularProgressIndicator()));
              //       }),
              // ),

              // SizedBox(height: 280, child: DetailGaugeDial(value: widget.values[1], isPressure: false)),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DataTestingPage(
                                dataService: dataService!,
                                timeService: timeService!,
                                pressureCharacteristic: pressureCharacteristic!,
                                flowCharacteristic: flowCharacteristic!,
                                timeCharacteristic: timeCharacteristic!)));
                  },
                  child: const Text('   Data Testing   ')),
            ],
          ),
        ),
      ),
    );
  }

  setDeviceTime() async {
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
  const DetailGaugeDial({Key? key, required this.value, required this.isPressure}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color1, color2, color3;
    double start1, start2, start3, end;
    String title;
    if (isPressure) {
      start1 = 0;
      start2 = 40;
      start3 = 60;
      end = 100;
      color1 = Colors.white;
      color2 = Colors.green;
      color3 = Colors.blue;
      title = 'Pressure';
    } else {
      start1 = 0;
      start2 = 25;
      start3 = 75;
      end = 100;
      color1 = Colors.green;
      color2 = Colors.orange;
      color3 = Colors.red;
      title = 'Flow';
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0.0, end: value),
            builder: (context, double tweenValue, child) {
              return RadialGauge(
                axes: [
                  RadialGaugeAxis(
                    minValue: 0,
                    maxValue: 300,
                    minAngle: -150,
                    maxAngle: 150,
                    radius: 0.9,
                    width: 0.14,
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
                      RadialTicks(interval: 20, alignment: RadialTickAxisAlignment.inside, color: Colors.white, length: 0.17, children: [
                        RadialTicks(
                          // interval: 50,
                          ticksInBetween: 5,
                          length: 0.13,
                          color: Colors.grey,
                        ),
                      ]),
                    ],
                    segments: [
                      RadialGaugeSegment(
                        minValue: 0,
                        maxValue: 100,
                        minAngle: -150,
                        maxAngle: -50,
                        color: color1,
                      ),
                      RadialGaugeSegment(
                        minValue: 100,
                        maxValue: 200,
                        minAngle: -50,
                        maxAngle: 50,
                        color: color2,
                      ),
                      RadialGaugeSegment(
                        minValue: 200,
                        maxValue: 300,
                        minAngle: 50,
                        maxAngle: 150,
                        color: color3,
                      ),
                    ],
                  ),
                ],
              );
            }),
        Padding(
          padding: const EdgeInsets.only(top: 120.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: 60,
                  height: 30,
                  child: FittedBox(
                    child: Text('${value.toStringAsFixed(2)}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                    // child: Text('820.88', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
              // Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ],
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
