import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flowprotest/single_chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gauges/gauges.dart';

class SingleReaderPage extends StatefulWidget {
  final List<BluetoothService> services;

  final String title;
  const SingleReaderPage({Key? key, required this.title, required this.services}) : super(key: key);

  @override
  State<SingleReaderPage> createState() => _SingleReaderPageState();
}

class _SingleReaderPageState extends State<SingleReaderPage> {
  Timer? _timer;
  bool isOn = true;
  late BluetoothService dataService;
  late BluetoothCharacteristic pressureCharacteristic;
  late BluetoothCharacteristic flowCharacteristic;

  // void startTimer() async {
  //   Random rand = Random();
  //   _timer = Timer.periodic(
  //     const Duration(seconds: 10),
  //     (Timer timer) {
  //       setState(() {
  //         for (var i = 0; i < widget.values.length; i++) {
  //           if (widget.values[i] < 5) {
  //             widget.values[i] += rand.nextInt(15) + 10;
  //           } else if (widget.values[i] > 95) {
  //             widget.values[i] -= rand.nextInt(15);
  //           } else if (widget.values[i] < 40) {
  //             widget.values[i] += rand.nextInt(15) + 5;
  //           } else {
  //             widget.values[i] += rand.nextInt(10) - 5;
  //           }
  //         }
  //       });
  //     },
  //   );
  // }
  void setupService() async {
    int serviceIndex = widget.services.indexWhere((element) => element.uuid.toString() == '8d8cceb9-ec48-4621-b293-0bafb0e0fa2d');
    dataService = widget.services[serviceIndex];
    int preassureIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '3300c0b5-2369-4322-8296-5564f44850b3');
    int flowIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '951770bd-a550-4466-b16f-4bc3170f4d0e');
    pressureCharacteristic = dataService.characteristics[preassureIndex];
    flowCharacteristic = dataService.characteristics[flowIndex];
    if (!pressureCharacteristic.isNotifying) {
      await pressureCharacteristic.setNotifyValue(true);
    }
    if (!flowCharacteristic.isNotifying) {
      await flowCharacteristic.setNotifyValue(true);
    }
  }

  @override
  void initState() {
    // startTimer();
    setupService();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              pressureCharacteristic: pressureCharacteristic,
                              flowCharacteristic: flowCharacteristic,
                            )));
              },
              icon: const Icon(Icons.bar_chart_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              // const Text('Status:'),
              // Text(
              //   isOn ? 'Operational' : 'Offline',
              //   style: TextStyle(color: isOn ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 10),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(primary: isOn ? Colors.blue : Colors.black),
              //   onPressed: () {
              //     setState(() {
              //       isOn = !isOn;
              //       if (isOn) {
              //         startTimer();
              //       } else {
              //         widget.values[0] = 0;
              //         widget.values[1] = 0;
              //         _timer?.cancel();
              //       }
              //     });
              //   },
              //   // color: isOn ? Colors.blue : Colors.black,
              //   child: const SizedBox(
              //     height: 70,
              //     child: Icon(
              //       Icons.power_settings_new,
              //       size: 40,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 10),
              StreamBuilder<List<int>>(
                  initialData: [0, 0, 0, 0],
                  // stream: widget.services[2].characteristics.firstWhere((element) => element.uuid == '3300c0b5-2369-4322-8296-5564f44850b3').value,
                  stream: pressureCharacteristic.value,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // return Text('${snapshot.data}');
                      if (snapshot.data?.length != 4) {
                        return Text('short');
                      }
                      var bytes = Uint8List.fromList(snapshot.data!);
                      var numberValue = ByteData.view(bytes.buffer).getInt32(0, Endian.host);
                      // TODO: do something with the data
                      if (numberValue > 0) {
                        return SizedBox(height: 280, child: DetailGaugeDial(value: ((numberValue - 1009000) / 1000), isPressure: true));
                      } else {
                        return Text('number less than 0');
                      }
                    } else if (snapshot.hasError) {
                      // TODO: do something with the error
                      return Text(snapshot.error.toString());
                    }
                    // TODO: the data is not ready, show a loading indicator
                    return Center(child: CircularProgressIndicator());
                  }),
              StreamBuilder<List<int>>(
                  // initialData: [0, 0, 0, 0],
                  // stream: widget.services[2].characteristics.firstWhere((element) => element.uuid == '3300c0b5-2369-4322-8296-5564f44850b3').value,
                  stream: flowCharacteristic.value,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // return Text('${snapshot.data}');
                      if (snapshot.data?.length != 4) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var bytes = Uint8List.fromList(snapshot.data!);
                      var numberValue = ByteData.view(bytes.buffer).getInt32(0, Endian.host);
                      // TODO: do something with the data
                      return SizedBox(height: 280, child: DetailGaugeDial(value: ((numberValue) / 1000), isPressure: false));
                    } else if (snapshot.hasError) {
                      // TODO: do something with the error
                      return Text(snapshot.error.toString());
                    }
                    // TODO: the data is not ready, show a loading indicator
                    return Center(child: CircularProgressIndicator());
                  }),
              // SizedBox(height: 280, child: DetailGaugeDial(value: widget.values[1], isPressure: false)),
            ],
          ),
        ),
      ),
    );
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
        RadialGauge(
          axes: [
            RadialGaugeAxis(
              minValue: 0,
              maxValue: 300,
              minAngle: -150,
              maxAngle: 150,
              radius: 0.9,
              width: 0.1,
              color: Colors.transparent,
              pointers: [RadialNeedlePointer(value: value, thicknessStart: 20, thicknessEnd: 0, length: 0.6, knobRadiusAbsolute: 10, color: Colors.white, knobColor: Colors.white)],
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
        ),
        Padding(
          padding: const EdgeInsets.only(top: 180.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${value}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
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
