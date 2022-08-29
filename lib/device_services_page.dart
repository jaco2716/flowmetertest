import 'dart:convert';
import 'dart:typed_data';
import 'package:flowprotest/model/providers/byte_data_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceServicesPage extends StatefulWidget {
  final List<BluetoothService> services;
  const DeviceServicesPage({Key? key, required this.services}) : super(key: key);

  @override
  State<DeviceServicesPage> createState() => _DeviceServicesPageState();
}

class _DeviceServicesPageState extends State<DeviceServicesPage> {
  List<List<int>> datasamples = [];
  int writeValue = 0;

  @override
  Widget build(BuildContext context) {
    // print('69, 39, =  ${ByteData.view(Uint8List.fromList([69, 39, 68, 39]).buffer).get(0, Endian.little)}');
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: ListView.builder(
        itemCount: widget.services.length,
        itemBuilder: (context, index) {
          var service = widget.services[index];
          // print('inc serv length: ${service.includedServices.length}');

          return ExpansionTile(
            key: GlobalKey(),
            title: Text('${service.uuid}'),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: service.characteristics.length,
                itemBuilder: (context, index3) {
                  var characteristic = service.characteristics[index3];
                  // print('characteristic :  ${characteristic.uuid}');
                  // print('Service :  ${service.uuid}');

                  return ChangeNotifierProvider<ByteDataProvider>(
                    create: (context) => ByteDataProvider(characteristic),
                    builder: (context, child) {
                      var byteDataProvider = Provider.of<ByteDataProvider>(context);
                      // print('char des length: ${characteristic.descriptors.length}');
                      return Column(
                        children: [
                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   itemCount: characteristic.descriptors.length,
                          //   itemBuilder: (context, indexdes) {
                          //     return Column(
                          //       children: [
                          //         Text(characteristic.descriptors[indexdes].uuid.toString()),
                          //         StreamBuilder<Object>(
                          //             stream: characteristic.descriptors[indexdes].value,
                          //             builder: (context, dessnapshot) {
                          //               return Text(dessnapshot.data.toString());
                          //             }),
                          //       ],
                          //     );
                          //   },
                          // ),
                          // byteDataProvider.characteristic.descriptors.isNotEmpty
                          //     ? ListView.builder(
                          //         shrinkWrap: true,
                          //         physics: const NeverScrollableScrollPhysics(),
                          //         itemCount: byteDataProvider.characteristic.descriptors.length,
                          //         itemBuilder: (context, index2) {
                          //           var descriptor = characteristic.descriptors[index2];
                          //           // print('\n\n\n\n ############### incl ################ \n\n\n\n');
                          //           return Card(
                          //             // child: Text('Descripters: ${descriptor.uuid}'),
                          //             color: Colors.red,
                          //             child: Padding(
                          //               padding: const EdgeInsets.all(8.0),
                          //               child: Column(
                          //                 children: [
                          //                   Text('${descriptor.uuid}'),
                          //                   ElevatedButton(
                          //                       onPressed: () {
                          //                         byteDataProvider.readDescriptor(index2);
                          //                       },
                          //                       child: const Text('Read')),
                          //                   Text('${byteDataProvider.descriptorData[index2]}')

                          //                   // if (characteristic.properties.read)
                          //                   //   FutureBuilder<List<int>?>(
                          //                   //       future: descriptor.read(),
                          //                   //       initialData: const [],
                          //                   //       builder: (context, snap) {
                          //                   //         try {
                          //                   //           if (snap.hasError) {
                          //                   //             return const Text('error');
                          //                   //           } else if (!snap.hasData) {
                          //                   //             return const Text('no data');
                          //                   //           } else if (snap.connectionState == ConnectionState.waiting) {
                          //                   //             return const Text('Loading');
                          //                   //           }
                          //                   //           print('\n\n\n\n ############### ${snap.data} ################ \n\n\n\n');

                          //                   //           return Text('${snap.data}');
                          //                   //         } catch (e) {
                          //                   //           return Text('$e');
                          //                   //         }
                          //                   //       }),
                          //                 ],
                          //               ),
                          //             ),
                          //           );
                          //         },
                          //       )
                          //     : const SizedBox.shrink(),
                          StreamProvider<List<int>>(
                              initialData: const [0],
                              create: (context) => characteristic.value,
                              // create: (context) => characteristic.value,
                              child: Card(
                                child: Column(
                                  children: [
                                    Text(
                                      '${characteristic.uuid}',
                                      style: const TextStyle(fontSize: 8),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          onPressed: characteristic.properties.read
                                              ? () async {
                                                  print('service id:  ${service.uuid}');
                                                  print('char id:  ${characteristic.uuid}');
                                                  // var sub = characteristic.value.listen((value) {
                                                  //   readValues[characteristic.uuid] = value;
                                                  // });
                                                  var data = await characteristic.read();
                                                  // var bytes = Uint8List.fromList([230, 7, 8, 5, 13, 12, 16, 5, 0, 0]);
                                                  var bytes = Uint8List.fromList(data);
                                                  // var yearValue = ByteData.view(bytes.buffer).getInt16(3, Endian.little);
                                                  // DateTime date = DateTime(yearValue, bytes[2 + 3], bytes[3 + 3], bytes[4 + 3], bytes[5 + 3], bytes[6 + 3]);
                                                  // var df = DateFormat('HH:mm:ss - dd/MM/yyyy');
                                                  // int start = 14;
                                                  // // print(data);
                                                  print(bytes);
                                                  // datasamples.add(data);
                                                  // print('Test date: ${df.format(date)}');
                                                  // int value = 2500;
                                                  // print('$value    = ${Uint8List(2)..buffer.asInt16List()[0] = value}');
                                                  // int end = 14;
                                                  // log('$datasamples');

                                                  // print('208, 7 = ${ByteData.view(Uint8List.fromList([60, 0]).buffer).getInt16(0, Endian.little)}');
                                                  // print('${bytes.sublist(start, start + 4)} = ${ByteData.view(Uint8List.fromList(data).buffer).getInt32(start, Endian.little)}');

                                                  // print(utf8.decode(bytes.sublist(0, 3), allowMalformed: true));
                                                  // String text = 'LPG';
                                                  // print('$text = ${utf8.encode('text')}');
//0 = type
//1-2 = index
//3-9 = time/date
//10-11 = Data Sample Rate
//12-13 = avgSensorPressure
//14-15 = maxSensorPressure
//16-17 = minSensorPressure
//18-20 ???
//21-22 = avgBarometer
//23-24 = maxBarometer
//25-26 = minBarometer
//27-28 = avgTemp
//29-30 = maxTemp
//31-32 = minTemp
//33-36 ???
//37-38 = maxMovement
//39-40 = minMovement
//41-47 ???
//
//
                                                  // sub.cancel();
                                                }
                                              : null,
                                          child: const Text('  Read  '),
                                        ),
                                        ElevatedButton(
                                          onPressed: characteristic.properties.write
                                              ? () async {
                                                  // Write flopro date
                                                  //  characteristic.write([208, 7, 1, 1, 2, 50, 58, 7, 0, 0]);
                                                  // characteristic.write([110, 101, 101, 100, 108, 105, 116, 101]);
                                                  // try {
                                                  //   // int value = 60;
                                                  //   // var dataValue = Uint8List(2)..buffer.asInt16List()[0] = value;
                                                  //   // print('$value    = $dataValue');
                                                  //   if (writeValue == 0) {
                                                  //     writeValue = 1;
                                                  //   } else {
                                                  //     writeValue = 0;
                                                  //   }
                                                  //   await characteristic.write([writeValue]);
                                                  // } on Exception catch (e) {
                                                  //   print(e.toString());
                                                  // }
                                                  // print('done');
                                                }
                                              : null,
                                          child: const Text('  Write  '),
                                        ),
                                        ElevatedButton(
                                          onPressed: characteristic.properties.notify
                                              ? () {
                                                  characteristic.setNotifyValue(true);
                                                }
                                              : null,
                                          child: const Text('  Notify  '),
                                        ),
                                        ElevatedButton(
                                          onPressed: characteristic.properties.notify
                                              ? () {
                                                  characteristic.setNotifyValue(false);
                                                  // print('charac :  ${characteristic.uuid}');
                                                }
                                              : null,
                                          child: const Text('  Stop  '),
                                        ),
                                      ],
                                    ),
                                    Consumer<List<int>>(builder: (context, List<int> data, _) {
                                      var bytes = Uint8List.fromList(data);
                                      var bytesResult = utf8.decode(bytes, allowMalformed: true);
                                      // print('Data parse: $bytesResult');
                                      String result = '--';
                                      if (service.uuid.toString() == '0000180a-0000-1000-8000-00805f9b34fb' ||
                                          characteristic.uuid.toString() == 'fdaffce0-85f8-4ac9-b0d2-8b133f8ea7b2' ||
                                          characteristic.uuid.toString() == '00002a00-0000-1000-8000-00805f9b34fb') {
                                        result = String.fromCharCodes(bytes);
                                      } else {
                                        if (bytes.lengthInBytes == 192) {
                                          result = '$data';
                                          // int bytelength = 2;
                                          // List<Uint8List> listlistbytes = [];
                                          // for (var i = 0; i < 192 / bytelength; i++) {
                                          //   listlistbytes.add(Uint8List(bytelength));
                                          //   for (var j = 0; j < bytelength; j++) {
                                          //     listlistbytes[i][j] = data[(i + 1) * j];
                                          //   }
                                          // }
                                          // List<int> resultList = [];
                                          // for (var i = 0; i < 192 / bytelength; i++) {
                                          //   resultList.add(ByteData.view(listlistbytes[i].buffer).getInt16(0, Endian.little));
                                          // }
                                          // // var numberValue = ByteData.view(bytes.buffer).getInt32(0, Endian.little);
                                          // // print('32bit - Lenght: ${bytes.lengthInBytes}, Value: $numberValue');
                                          // // print(data);
                                          // result = '$resultList';
                                        } else if (bytes.lengthInBytes == 10) {
                                          var bytes2 = Uint8List.fromList([16, 10, 0, 208, 7, 1, 1, 4, 32, 13]);
                                          var yearValue2 = ByteData.view(bytes2.buffer).getInt16(0, Endian.little);
                                          DateTime date2 = DateTime(yearValue2, bytes2[2], bytes2[3], bytes2[4], bytes2[5], bytes2[6]);
                                          var yearValue = ByteData.view(bytes.buffer).getInt16(0, Endian.little);
                                          DateTime date = DateTime(yearValue, bytes[2], bytes[3], bytes[4], bytes[5], bytes[6]);
                                          var df = DateFormat('HH:mm:ss - dd/MM/yyyy');
                                          print('Test date: ${df.format(date2)}');
                                          // print('32bit - Lenght: ${bytes.lengthInBytes}, Value: $numberValue');
                                          // print(yearValue);

                                          result = df.format(date);
                                        } else if (bytes.lengthInBytes == 4) {
                                          var numberValue = ByteData.view(bytes.buffer).getInt32(0, Endian.little);
                                          // print('32bit - Lenght: ${bytes.lengthInBytes}, Value: $numberValue');
                                          result = '$data - RAW';
                                          // result = '$numberValue - 32byte';
                                        } else if (bytes.lengthInBytes == 2) {
                                          var numberValue = ByteData.view(bytes.buffer).getInt16(0, Endian.little);
                                          // print('16bit - Lenght: ${bytes.lengthInBytes}, Value: $numberValue');
                                          result = '$numberValue - 16byte';
                                        } else if (bytes.lengthInBytes == 1) {
                                          var numberValue = ByteData.view(bytes.buffer).getInt8(0);
                                          // print('8bit - Lenght: ${bytes.lengthInBytes}, Value: $numberValue');
                                          result = '$numberValue - 8byte';
                                        } else if (bytes.lengthInBytes == 0) {
                                          result = 'NULL';
                                        } else {
                                          if (bytes.lengthInBytes == 16) {
                                            // print('\n\n\n ############# 64 byte ############ \n\n\n');
                                            result = '\n\n\n ############# 64 byte ############ \n\n\n';
                                          } else {
                                            // result = data.toString();
                                            result = '$data (RAW)';
                                          }
                                        }
                                      }

                                      var newint8list = Uint8List.fromList([16, 59, 1, 230]);
                                      var newint8result = ByteData.view(newint8list.buffer).getInt16(0, Endian.little);
                                      // print('newint8:  $newint8result');

                                      // print('Lenght: ${bytes.lengthInBytes}');
                                      // print('length/4: ${bytes.lengthInBytes / 4}');

                                      // print(bytes);

                                      // var bytedata = ByteData.sublistView(bytes);
                                      // var byteLength = bytedata.lengthInBytes;
                                      // // var bytesResult = utf8.decode(bytes, allowMalformed: true);
                                      // var bytesResult = String.fromCharCodes(bytes);
                                      // var doubleValue = bytes.; //.getFloat64(0);
                                      // List<int> floatList = bytes.buffer.asInt32List().toList();
                                      // if (data.isNotEmpty) {
                                      //   print('codeunits: $data - ${data}');
                                      //   var salr = String.fromCharCodes(data);
                                      //   print('String: $salr');

                                      //   var string = ascii.decode(data, allowInvalid: true);
                                      //   print('Lenght: $byteLength - Bytes: $string'); // Prints: 3.141592653589793
                                      // }
                                      // var result = floatList.isNotEmpty ? String.fromCharCodes(bytes) : 'Intet';
                                      // List<double> floatList = bytes.buffer.().toList();

                                      return Text('Value: $result');
                                    })
                                  ],
                                ),
                              )),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
