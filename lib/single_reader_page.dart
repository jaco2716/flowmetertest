import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flowprotest/single_chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gauges/gauges.dart';
import 'package:intl/intl.dart';

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
  late BluetoothService timeService;
  late BluetoothCharacteristic pressureCharacteristic;
  late BluetoothCharacteristic flowCharacteristic;
  late BluetoothCharacteristic timeCharacteristic;
  List<List<int>> dateData = [];
  bool isNotifying = false;

  void setupService() async {
    int timeServiceIndex = widget.services.indexWhere((element) => element.uuid.toString() == '00001805-0000-1000-8000-00805f9b34fb');
    timeService = widget.services[timeServiceIndex];
    int timeIndex = timeService.characteristics.indexWhere((element) => element.uuid.toString() == '00002a2b-0000-1000-8000-00805f9b34fb');
    timeCharacteristic = timeService.characteristics[timeIndex];

    int serviceIndex = widget.services.indexWhere((element) => element.uuid.toString() == '8d8cceb9-ec48-4621-b293-0bafb0e0fa2d');
    dataService = widget.services[serviceIndex];
    int preassureIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '3300c0b5-2369-4322-8296-5564f44850b3');
    pressureCharacteristic = dataService.characteristics[preassureIndex];
    int flowIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '7cb8e55f-d785-4c62-b6f7-ba6ba7581b7b');
    // int flowIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '951770bd-a550-4466-b16f-4bc3170f4d0e');
    flowCharacteristic = dataService.characteristics[flowIndex];
    if (!timeCharacteristic.isNotifying) {
      await timeCharacteristic.setNotifyValue(isNotifying);
    }
    if (!pressureCharacteristic.isNotifying) {
      await pressureCharacteristic.setNotifyValue(isNotifying);
    }
    if (!flowCharacteristic.isNotifying) {
      await flowCharacteristic.setNotifyValue(isNotifying);
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
    if (dateData.length > 4) {
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

      // print('$testValue = ${ByteData.view(Uint8List.fromList(testValue).buffer).getInt16(0, Endian.host)}');
      // print('$testValue2 = ${ByteData.view(Uint8List.fromList(testValue2).buffer).getInt16(0, Endian.host)}');
      // print('$testValue3 = ${ByteData.view(Uint8List.fromList(testValue3).buffer).getInt16(0, Endian.host)}');
      // print('$testValue4 = ${ByteData.view(Uint8List.fromList(testValue4).buffer).getInt16(0, Endian.host)}');
      // print('$testValue5 = ${ByteData.view(Uint8List.fromList(testValue5).buffer).getInt16(0, Endian.host)}');

      // print(dateData[0][21]);
    }

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
            mainAxisSize: MainAxisSize.min,
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
                        return const Text('No data');
                      }
                      var bytes = Uint8List.fromList(snapshot.data!);
                      var numberValue = ByteData.view(bytes.buffer).getUint32(0, Endian.host);
                      // TODO: do something with the data
                      if (numberValue > 0) {
                        return SizedBox(height: 280, child: DetailGaugeDial(value: ((numberValue.toDouble() - 1021200) / 1000), isPressure: true));
                      } else {
                        return const Text('number less than 0');
                      }
                    } else if (snapshot.hasError) {
                      // TODO: do something with the error
                      return Text(snapshot.error.toString());
                    }
                    // TODO: the data is not ready, show a loading indicator
                    return const Center(child: CircularProgressIndicator());
                  }),
              StreamBuilder<List<int>>(
                  // initialData: [0, 0, 0, 0],
                  // stream: widget.services[2].characteristics.firstWhere((element) => element.uuid == '3300c0b5-2369-4322-8296-5564f44850b3').value,
                  stream: flowCharacteristic.value,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // return Text('${snapshot.data}');
                      if (snapshot.data?.length != 4) {
                        return const Text('No data');
                      }
                      var bytes = Uint8List.fromList(snapshot.data!);
                      var numberValue = ByteData.view(bytes.buffer).getInt32(0, Endian.host);
                      // TODO: do something with the data
                      return SizedBox(height: 280, child: DetailGaugeDial(value: (((numberValue.toDouble() * 70 / 1000))), isPressure: false));
                      // return SizedBox(height: 280, child: DetailGaugeDial(value: (((numberValue.toDouble() / 10000 - 16))), isPressure: false));
                    } else if (snapshot.hasError) {
                      // TODO: do something with the error
                      return Text(snapshot.error.toString());
                    }
                    // TODO: the data is not ready, show a loading indicator
                    return const Center(child: CircularProgressIndicator());
                  }),
              // SizedBox(height: 280, child: DetailGaugeDial(value: widget.values[1], isPressure: false)),
              StreamBuilder<List<int>>(
                  stream: timeCharacteristic.value,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data?.isEmpty ?? true) {
                        return const Text('No data');
                      }
                      var bytes = Uint8List.fromList(snapshot.data!);
                      var yearValue = ByteData.view(bytes.buffer).getInt16(0, Endian.host);
                      DateTime date = DateTime(yearValue, bytes[2], bytes[3], bytes[4], bytes[5], bytes[6]);
                      var df = DateFormat('HH:mm:ss - dd/MM/yyyy');
                      return Text(df.format(date));
                    } else if (snapshot.hasError) {
                      // TODO: do something with the error
                      return Text(snapshot.error.toString());
                    }
                    // TODO: the data is not ready, show a loading indicator
                    return const Center(child: CircularProgressIndicator());
                  }),
              ElevatedButton(
                  onPressed: () {
                    print('setting ${!isNotifying}');
                    changeNotifying(!isNotifying);
                    isNotifying = !isNotifying;
                  },
                  child: const Text('Change Notify')),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          DateTime timeNow = DateTime.now();
                          var yearByte = Uint8List(2)..buffer.asInt16List()[0] = timeNow.year;
                          List<int> timeNowBytes = [];
                          timeNowBytes.addAll(yearByte);
                          timeNowBytes.addAll([timeNow.month, timeNow.day, timeNow.hour, timeNow.minute, timeNow.second, 7, 0, 0]);
                          await timeCharacteristic.write(timeNowBytes);
                        } on Exception catch (e) {
                          print(e.toString());
                        }
                      },
                      child: const Text('   Set Time   ')),
                  ElevatedButton(
                      onPressed: () async {
                        //4afa9a10-05ec-482c-8279-3ebf3c3e1b74
                        try {
                          int sampleRateIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '4afa9a10-05ec-482c-8279-3ebf3c3e1b74');
                          BluetoothCharacteristic sampleRateCharacteristic = dataService.characteristics[sampleRateIndex];
                          List<int> sampleRate = Uint8List(2)..buffer.asInt16List()[0] = 60;
                          await sampleRateCharacteristic.write(sampleRate);
                        } on Exception catch (e) {
                          print(e.toString());
                        }
                      },
                      child: const Text('Sample Rate')),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        int dataLengthIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '8b8df99d-c029-459f-a213-9e9ecac551bf');
                        int dataIdIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '1c70d98c-935b-4ff3-ae08-a1cda58c34fa');

                        BluetoothCharacteristic dataLengthCharacteristic = dataService.characteristics[dataLengthIndex];
                        BluetoothCharacteristic dataIdCharacteristic = dataService.characteristics[dataIdIndex];

                        var dataLength = await dataLengthCharacteristic.read();

                        try {
                          int dataLenghtInt = ByteData.view(Uint8List.fromList(dataLength).buffer).getInt16(0, Endian.host);
                          // var dataIdResult = await dataIdCharacteristic.write(Uint8List(2)..buffer.asInt16List()[0] = dataLenghtInt - 1);
                          var dataIdResult = await dataIdCharacteristic.write([1, 0]);
                          print('result: $dataIdResult - Length: $dataLength');
                        } on Exception catch (e) {
                          print(e.toString());
                        }
                      },
                      child: const Text('Reset Index')),
                  ElevatedButton(
                    onPressed: () async {
                      //service id: 8d8cceb9-ec48-4621-b293-0bafb0e0fa2d
                      //char id:  03ee8a35-7a28-4cd9-affe-8d0205b4b093
                      //1c70d98c-935b-4ff3-ae08-a1cda58c34fa
                      //8b8df99d-c029-459f-a213-9e9ecac551bf

                      int dateDataIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '03ee8a35-7a28-4cd9-affe-8d0205b4b093');
                      BluetoothCharacteristic dateDataCharacteristic = dataService.characteristics[dateDataIndex];
                      // var dataLength = await dataLengthCharacteristic.read();
                      // await Future.delayed(const Duration(milliseconds: 100));

                      // try {
                      //   int dataLenghtInt = ByteData.view(Uint8List.fromList(dataLength).buffer).getInt16(0, Endian.host);
                      //   // var dataIdResult = await dataIdCharacteristic.write(Uint8List(2)..buffer.asInt16List()[0] = dataLenghtInt - 1);
                      //   var dataIdResult = await dataIdCharacteristic.write([29, 0]);
                      //   print('result: $dataIdResult - Length: $dataLength');
                      // } on Exception catch (e) {
                      //   print(e.toString());
                      // }
                      var data = await dateDataCharacteristic.read();
                      for (var i = 0; i < data.length / 48; i++) {
                        dateData.add(data.sublist(i * 48, i * 48 + 48));

                        // print('${data.sublist(i * 48 + 1, i * 48 + 3)}- i=18: ${data.sublist(i * 48 + 18, i * 48 + 48)}');
                        print('${data.sublist(i * 48, i * 48 + 48)}');
                        // print(
                        //     '18-20:${data.sublist(i * 48 + 18, i * 48 + 21)}- 33:36${data.sublist(i * 48 + 33, i * 48 + 37)}- 41:47${data.sublist(i * 48 + 41, i * 48 + 48)}');
                      }
                      // dateData.sort(
                      //   (a, b) {
                      //     var bytesa = Uint8List.fromList(a);
                      //     var bytesb = Uint8List.fromList(b);

                      //     int dataIndexa = ByteData.view(bytesa.buffer).getInt16(1, Endian.host);
                      //     int dataIndexb = ByteData.view(bytesb.buffer).getInt16(1, Endian.host);
                      //     return dataIndexa.compareTo(dataIndexb);
                      //   },
                      // );
                      print('data. $data');

                      print(data.length);
                      setState(() {});
                      // dateData.clear();
                    },
                    child: const Text('       Data       '),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1510,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(width: 215, color: Colors.black, child: const Text('')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 165, color: Colors.black, child: const Text('  Flow[CFH]')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 165, color: Colors.black, child: const Text(' Capacity [BTU/hr]')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 165, color: Colors.black, child: const Text('  Pressure[Pa]')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 110, color: Colors.black, child: const Text('  Movement')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 165, color: Colors.black, child: const Text('  Temperature')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 165, color: Colors.black, child: const Text('  Barometer[HG]')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                        ],
                      ),
                      Row(
                        children: [
                          Container(width: 40, color: Colors.black, child: const Text('ID')),
                          Container(width: 100, color: Colors.white10, child: const Text('Date')),
                          Container(width: 35, color: Colors.black, child: const Text('Type')),
                          Container(width: 40, color: Colors.white10, child: const Text('Smlp')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 55, color: Colors.black, child: const Text('Avg')),
                          Container(width: 55, color: Colors.white10, child: const Text('Max')),
                          Container(width: 55, color: Colors.black, child: const Text('Min')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 55, color: Colors.white10, child: const Text('Avg')),
                          Container(width: 55, color: Colors.black, child: const Text('Max')),
                          Container(width: 55, color: Colors.white10, child: const Text('Min')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 55, color: Colors.black, child: const Text('Avg')),
                          Container(width: 55, color: Colors.white10, child: const Text('Max')),
                          Container(width: 55, color: Colors.black, child: const Text('Min')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 55, color: Colors.white10, child: const Text('Min')),
                          Container(width: 55, color: Colors.black, child: const Text('Max')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 55, color: Colors.black, child: const Text('Avg')),
                          Container(width: 55, color: Colors.white10, child: const Text('Max')),
                          Container(width: 55, color: Colors.black, child: const Text('Min')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 55, color: Colors.white10, child: const Text('Avg')),
                          Container(width: 55, color: Colors.black, child: const Text('Max')),
                          Container(width: 55, color: Colors.black, child: const Text('Min')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                        ],
                      ),
                      Container(color: Colors.white, width: 1510, height: 1),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dateData.length,
                        itemBuilder: (context, index) {
                          String dataIndex = '', dateString = '', typeString = '', sample = '', avgSensorPressure = '', maxSensorPressure = '', minSensorPressure = '', maxMovement = '', minMovement = '', avgTemp = '', minTemp = '', maxTemp = '', avgBarometer = '', maxBarometer = '', minBarometer = '', avgFlow = '', maxFlow = '', minFlow = '';
                          var data = dateData[index];
                          var bytes = Uint8List.fromList(data);
                          dataIndex = ByteData.view(bytes.buffer).getInt16(1, Endian.host).toString();
                          // if (data[0] == 16) {
                          typeString = data[0].toString();
                          var yearValue = ByteData.view(bytes.buffer).getInt16(3, Endian.host);
                          DateTime date = DateTime(yearValue, bytes[2 + 3], bytes[3 + 3], bytes[4 + 3], bytes[5 + 3], bytes[6 + 3]);
                          var df = DateFormat('HH:mm|d/M/yy');
                          dateString = df.format(date);
                          sample = ByteData.view(bytes.buffer).getInt16(10, Endian.host).toString();
                          avgSensorPressure = (ByteData.view(bytes.buffer).getInt16(12, Endian.host) / 100).toStringAsFixed(2);
                          maxSensorPressure = (ByteData.view(bytes.buffer).getInt16(14, Endian.host) / 100).toStringAsFixed(2);
                          minSensorPressure = (ByteData.view(bytes.buffer).getInt16(16, Endian.host) / 100).toStringAsFixed(2);
                          maxMovement = (ByteData.view(bytes.buffer).getInt16(37, Endian.host)).toString();
                          minMovement = (ByteData.view(bytes.buffer).getInt16(39, Endian.host)).toString();
                          avgTemp = (((((ByteData.view(bytes.buffer).getInt16(27, Endian.host) / 10) * 9 / 5) + 32) * 10).toInt() / 10).toStringAsFixed(1);
                          minTemp = (((((ByteData.view(bytes.buffer).getInt16(29, Endian.host) / 10) * 9 / 5) + 32) * 10).toInt() / 10).toStringAsFixed(1);
                          maxTemp = (((((ByteData.view(bytes.buffer).getInt16(31, Endian.host) / 10) * 9 / 5) + 32) * 10).toInt() / 10).toStringAsFixed(1);
                          avgBarometer = ((ByteData.view(bytes.buffer).getInt16(21, Endian.host) * 29.53) / 100 / 100).toStringAsFixed(2);
                          maxBarometer = ((ByteData.view(bytes.buffer).getInt16(23, Endian.host) * 29.53) / 100 / 100).toStringAsFixed(2);
                          minBarometer = ((ByteData.view(bytes.buffer).getInt16(25, Endian.host) * 29.53) / 100 / 100).toStringAsFixed(2);
                          avgFlow = ((ByteData.view(bytes.buffer).getInt32(33, Endian.host)) / 10000).toStringAsFixed(2);
                          // } else {
                          //   // dateString = ByteData.view(Uint8List.fromList([0, 76]).buffer).getInt16(0, Endian.host).toString();
                          //   dateString = ByteData.view(bytes.buffer).getInt16(1, Endian.host).toString();
                          // }

                          String restOfData = data.sublist(18, 21).toString();
                          restOfData += data.sublist(33, 37).toString();
                          restOfData += data.sublist(41).toString();

                          // Text('$dataIndex|${df.format(date)}|${bytes[0]}  |$sample  |$avgSensorPressure|$maxSensorPressure|$minSensorPressure||||'),
                          return Row(
                            children: [
                              Container(width: 40, color: Colors.black, child: Text(dataIndex)),
                              Container(width: 100, color: Colors.white10, child: Text(dateString)),
                              Container(width: 35, color: Colors.black, child: Text(typeString)),
                              Container(width: 40, color: Colors.white10, child: Text(sample)),
                              Container(width: 1, color: Colors.white, child: const Text('')),
                              Container(width: 55, color: Colors.black, child: Text(avgFlow)),
                              Container(width: 55, color: Colors.white10, child: Text('-')),
                              Container(width: 55, color: Colors.black, child: Text('-')),
                              Container(width: 1, color: Colors.white, child: const Text('')),
                              Container(width: 55, color: Colors.white10, child: Text('-')),
                              Container(width: 55, color: Colors.black, child: Text('-')),
                              Container(width: 55, color: Colors.white10, child: Text('-')),
                              Container(width: 1, color: Colors.white, child: const Text('')),
                              Container(width: 55, color: Colors.black, child: Text(avgSensorPressure)),
                              Container(width: 55, color: Colors.white10, child: Text(maxSensorPressure)),
                              Container(width: 55, color: Colors.black, child: Text(minSensorPressure)),
                              Container(width: 1, color: Colors.white, child: const Text('')),
                              Container(width: 55, color: Colors.white10, child: Text(minMovement)),
                              Container(width: 55, color: Colors.black, child: Text(maxMovement)),
                              Container(width: 1, color: Colors.white, child: const Text('')),
                              Container(width: 55, color: Colors.white10, child: Text(avgTemp)),
                              Container(width: 55, color: Colors.black, child: Text(maxTemp)),
                              Container(width: 55, color: Colors.white10, child: Text(minTemp)),
                              Container(width: 1, color: Colors.white, child: const Text('')),
                              Container(width: 55, color: Colors.black, child: Text(avgBarometer)),
                              Container(width: 55, color: Colors.white10, child: Text(minBarometer)),
                              Container(width: 55, color: Colors.black, child: Text(maxBarometer)),
                              Container(width: 1, color: Colors.white, child: const Text('')),
                              Container(width: 350, color: Colors.black, child: Text(restOfData)),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  changeNotifying(bool notify) async {
    await timeCharacteristic.setNotifyValue(notify);
    await pressureCharacteristic.setNotifyValue(notify);
    await flowCharacteristic.setNotifyValue(notify);
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
                    width: 0.1,
                    color: Colors.transparent,
                    pointers: [RadialNeedlePointer(value: tweenValue, thicknessStart: 20, thicknessEnd: 0, length: 0.6, knobRadiusAbsolute: 10, color: Colors.white, knobColor: Colors.white)],
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
          padding: const EdgeInsets.only(top: 180.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(value * 100).round() / 100}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
