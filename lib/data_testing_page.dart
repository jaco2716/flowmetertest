import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';

class DataTestingPage extends StatefulWidget {
  final BluetoothService dataService;
  final BluetoothService timeService;
  final BluetoothCharacteristic pressureCharacteristic;
  final BluetoothCharacteristic flowCharacteristic;
  final BluetoothCharacteristic timeCharacteristic;

  const DataTestingPage({
    Key? key,
    required this.dataService,
    required this.timeService,
    required this.pressureCharacteristic,
    required this.flowCharacteristic,
    required this.timeCharacteristic,
  }) : super(key: key);

  @override
  _DataTestingPageState createState() => _DataTestingPageState();
}

class _DataTestingPageState extends State<DataTestingPage> {
  List<List<int>> dateData = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Testing'),
      ),
      body: Column(
        children: [
          //Testing with data
          // ElevatedButton(
          //     onPressed: () {
          //       print('setting ${!isNotifying}');
          //       changeNotifying(!isNotifying);
          //       isNotifying = !isNotifying;
          //     },
          //     child: const Text('Change Notify')),

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
                      await widget.timeCharacteristic.write(timeNowBytes);
                    } on Exception catch (e) {
                      print(e.toString());
                    }
                  },
                  child: const Text('   Set Time   ')),
              ElevatedButton(
                  onPressed: () async {
                    //4afa9a10-05ec-482c-8279-3ebf3c3e1b74
                    try {
                      int sampleRateIndex = widget.dataService.characteristics
                          .indexWhere((element) => element.uuid.toString() == '4afa9a10-05ec-482c-8279-3ebf3c3e1b74');
                      BluetoothCharacteristic? sampleRateCharacteristic = widget.dataService.characteristics[sampleRateIndex];
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
                    // int dataLengthIndex =
                    //     dataService?.characteristics.indexWhere((element) => element.uuid.toString() == '8b8df99d-c029-459f-a213-9e9ecac551bf') ?? -1;
                    int dataIdIndex =
                        widget.dataService.characteristics.indexWhere((element) => element.uuid.toString() == '1c70d98c-935b-4ff3-ae08-a1cda58c34fa');

                    // BluetoothCharacteristic? dataLengthCharacteristic = dataService?.characteristics[dataLengthIndex];
                    BluetoothCharacteristic? dataIdCharacteristic = widget.dataService.characteristics[dataIdIndex];

                    // var dataLength = await dataLengthCharacteristic?.read();

                    try {
                      // int dataLenghtInt = ByteData.view(Uint8List.fromList(dataLength?).buffer).getInt16(0, Endian.little);
                      // var dataIdResult = await dataIdCharacteristic.write(Uint8List(2)..buffer.asInt16List()[0] = dataLenghtInt - 1);
                      await dataIdCharacteristic.write([1, 0]);
                      // print('result: $dataIdResult - Length: $dataLength');
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

                  int dateDataIndex =
                      widget.dataService.characteristics.indexWhere((element) => element.uuid.toString() == '03ee8a35-7a28-4cd9-affe-8d0205b4b093');
                  BluetoothCharacteristic? dateDataCharacteristic = widget.dataService.characteristics[dateDataIndex];
                  // var dataLength = await dataLengthCharacteristic.read();
                  // await Future.delayed(const Duration(milliseconds: 100));

                  // try {
                  //   int dataLenghtInt = ByteData.view(Uint8List.fromList(dataLength).buffer).getInt16(0, Endian.little);
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

                  //     int dataIndexa = ByteData.view(bytesa.buffer).getInt16(1, Endian.little);
                  //     int dataIndexb = ByteData.view(bytesb.buffer).getInt16(1, Endian.little);
                  //     return dataIndexa.compareTo(dataIndexb);
                  //   },
                  // );
                  print('data. $data');

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
                      String dataIndex = '',
                          dateString = '',
                          typeString = '',
                          sample = '',
                          avgSensorPressure = '',
                          maxSensorPressure = '',
                          minSensorPressure = '',
                          maxMovement = '',
                          minMovement = '',
                          avgTemp = '',
                          minTemp = '',
                          maxTemp = '',
                          avgBarometer = '',
                          maxBarometer = '',
                          minBarometer = '',
                          avgFlow = '',
                          maxFlow = '',
                          minFlow = '';
                      var data = dateData[index];
                      var bytes = Uint8List.fromList(data);
                      dataIndex = ByteData.view(bytes.buffer).getInt16(1, Endian.little).toString();
                      // if (data[0] == 16) {
                      typeString = data[0].toString();
                      var yearValue = ByteData.view(bytes.buffer).getInt16(3, Endian.little);
                      DateTime date = DateTime(yearValue, bytes[2 + 3], bytes[3 + 3], bytes[4 + 3], bytes[5 + 3], bytes[6 + 3]);
                      var df = DateFormat('HH:mm|d/M/yy');
                      dateString = df.format(date);
                      sample = ByteData.view(bytes.buffer).getInt16(10, Endian.little).toString();
                      avgSensorPressure = (ByteData.view(bytes.buffer).getInt16(12, Endian.little) / 100).toStringAsFixed(2);
                      maxSensorPressure = (ByteData.view(bytes.buffer).getInt16(14, Endian.little) / 100).toStringAsFixed(2);
                      minSensorPressure = (ByteData.view(bytes.buffer).getInt16(16, Endian.little) / 100).toStringAsFixed(2);
                      maxMovement = (ByteData.view(bytes.buffer).getInt16(37, Endian.little)).toString();
                      minMovement = (ByteData.view(bytes.buffer).getInt16(39, Endian.little)).toString();
                      avgTemp =
                          (((((ByteData.view(bytes.buffer).getInt16(27, Endian.little) / 10) * 9 / 5) + 32) * 10).toInt() / 10).toStringAsFixed(1);
                      minTemp =
                          (((((ByteData.view(bytes.buffer).getInt16(29, Endian.little) / 10) * 9 / 5) + 32) * 10).toInt() / 10).toStringAsFixed(1);
                      maxTemp =
                          (((((ByteData.view(bytes.buffer).getInt16(31, Endian.little) / 10) * 9 / 5) + 32) * 10).toInt() / 10).toStringAsFixed(1);
                      avgBarometer = ((ByteData.view(bytes.buffer).getInt16(21, Endian.little) * 29.53) / 100 / 100).toStringAsFixed(2);
                      maxBarometer = ((ByteData.view(bytes.buffer).getInt16(23, Endian.little) * 29.53) / 100 / 100).toStringAsFixed(2);
                      minBarometer = ((ByteData.view(bytes.buffer).getInt16(25, Endian.little) * 29.53) / 100 / 100).toStringAsFixed(2);
                      avgFlow = ((ByteData.view(bytes.buffer).getInt32(33, Endian.little)) / 10000).toStringAsFixed(2);
                      // } else {
                      //   // dateString = ByteData.view(Uint8List.fromList([0, 76]).buffer).getInt16(0, Endian.little).toString();
                      //   dateString = ByteData.view(bytes.buffer).getInt16(1, Endian.little).toString();
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
                          Container(width: 55, color: Colors.white10, child: const Text('-')),
                          Container(width: 55, color: Colors.black, child: const Text('-')),
                          Container(width: 1, color: Colors.white, child: const Text('')),
                          Container(width: 55, color: Colors.white10, child: const Text('-')),
                          Container(width: 55, color: Colors.black, child: const Text('-')),
                          Container(width: 55, color: Colors.white10, child: const Text('-')),
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
          ),
        ],
      ),
    );
  }
}
