import 'dart:async';

import 'package:flowprotest/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'device_services_page.dart';
import 'my_alert_dialog.dart';
import 'single_reader_page.dart';

class SelectBtDevice extends StatefulWidget {
  const SelectBtDevice({Key? key}) : super(key: key);

  @override
  State<SelectBtDevice> createState() => _SelectBtDeviceState();
}

class _SelectBtDeviceState extends State<SelectBtDevice> {
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> allResults = [];
  bool canRefresh = true;
  BluetoothDevice? connectDevice;
  bool disconnect = false;
  List<BluetoothService>? _services;

  Future<dynamic> _findPrinters() async {
    // Start scanning
    return await flutterBlue.startScan(timeout: const Duration(seconds: 4));
  }

  Future<BluetoothDevice?> gettingConnection({required BluetoothDevice? connectDevice, required bool disconnect}) async {
    print('getConnection');
    try {
      if (connectDevice != null && disconnect == false) {
        // await connectDevice.connect(timeout: const Duration(seconds: 1)).catchError((e) {
        //   print('#### error connecting ###');
        // });
        bool? result;
        await connectDevice.connect(autoConnect: false).timeout(const Duration(seconds: 8), onTimeout: () {
          debugPrint('timeout occured');
          connectDevice.disconnect();
          showMyDialog(context, 'Fejl', 'Kunne ikke forbinde til enheden.\nDen er muligvis forbundet til en anden enhed allerede.');
          result = false;
        });
        if (result == null) {
          _services = await connectDevice.discoverServices();
          return connectDevice;
        } else {
          return null;
        }
      } else {
        var devices = await flutterBlue.connectedDevices;
        if (devices.isNotEmpty) {
          if (disconnect) {
            await devices.first.disconnect();
            return null;
          } else {
            _services = await devices.first.discoverServices();
            return devices.first;
          }
        }
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // void listenToStream(Stream<List<int>>? value) {
  //   StreamController<List<int>> _controller =
  //       StreamController<List<int>>.broadcast();
  //   _controller.add(value!);
  //   print('Stream Started: ${value.length}');
  //   _controller.stream.listen((event) => print(event));
  //   // streamValue = value.asBroadcastStream().listen((event) {
  //   //   print(event);
  //   // });
  // }

  @override
  void dispose() {
    flutterBlue.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),
          SizedBox(
            height: 80,
            child: Image.asset(
              'assets/logo/logo_light.png',
            ),
          ),
          const SizedBox(
            height: 10,
            width: double.infinity,
          ),
          const Text(
            'Connect to a bluetooth device',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          FutureBuilder<BluetoothDevice?>(
              future: gettingConnection(connectDevice: connectDevice, disconnect: disconnect),
              builder: (context, snapshot) {
                print(snapshot.data);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data != null) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => SingleReaderPage(
                  //       title: snapshot.data!.name,
                  //       services: _services!,
                  //     ),
                  //   ),
                  // );
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      const Text('Connected to', style: TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                      Text(snapshot.data!.name, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white70), textAlign: TextAlign.center),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              disconnect = true;
                            });
                          },
                          child: const Text('Disconnect')),
                      TextButton(
                          onPressed: () async {
                            // var btServices = await snapshot.data?.discoverServices();
                            // print('\n\n\n #### services ${snapshot.data!.services.first} ### \n\n\n');
                            // print('services amount: ${btServices?.length}');
                            // var charactoristics = btServices?[4].characteristics;
                            // print(charactoristics?[0].value);
                            // listenToStream(charactoristics![0].value);
                            if (mounted) {
                              // print('char amount: ${charactoristics?[0].descriptors.length}');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeviceServicesPage(services: _services!),
                                  ));
                            }
                          },
                          child: const Text('Discover services')),
                      TextButton(
                          onPressed: () async {
                            if (mounted) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SingleReaderPage(
                                      services: _services!,
                                      title: snapshot.data!.name,
                                    ),
                                  ));
                            }
                          },
                          child: const Text('See Data')),
                    ],
                  );
                }
                return StreamBuilder<List<ScanResult>>(
                    stream: flutterBlue.scanResults,
                    builder: (context, scanSnapshot) {
                      print('scansnapsghot: ${scanSnapshot.data}');
                      if (scanSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      allResults = scanSnapshot.data!;
                      var newResults = allResults.where((element) => element.device.name.contains('FloPro')).toList();
                      newResults.sort((a, b) => a.device.name.isEmpty ? 1 : a.device.name.compareTo(b.device.name.isEmpty ? 'zzzzz' : b.device.name));
                      if (newResults.isEmpty) {
                        return Column(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  if (canRefresh) {
                                    canRefresh = false;
                                    await flutterBlue.stopScan();
                                    await Future.delayed(
                                        const Duration(
                                          milliseconds: 300,
                                        ),
                                        () => _findPrinters());
                                    canRefresh = true;
                                  }
                                },
                                icon: const Icon(Icons.refresh)),
                            const Center(child: Text('Ingen enheder fundet.')),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          IconButton(
                              onPressed: () async {
                                if (canRefresh) {
                                  canRefresh = false;
                                  await flutterBlue.stopScan();
                                  await Future.delayed(
                                      const Duration(
                                        milliseconds: 300,
                                      ),
                                      () => _findPrinters());
                                  canRefresh = true;
                                }
                              },
                              icon: const Icon(Icons.refresh)),
                          SizedBox(
                            height: 300,
                            width: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 25),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          disconnect = false;
                                          connectDevice = newResults[index].device;
                                        });
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => SingleReaderPage(
                                        //       title: newResults[index].device.name.isEmpty ? '....' : newResults[index].device.name,

                                        //       services: widget.services,
                                        //     ),
                                        //   ),
                                        // );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Padding(
                                          //   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 25),
                                          //   child: Icon(Icons.webhook_outlined),
                                          // ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  newResults[index].device.name.isEmpty ? '....' : newResults[index].device.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  newResults[index].device.id.id,
                                                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(
                                            Icons.link,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                                return Card(
                                  child: ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    title: Text(newResults[index].device.name.isEmpty ? '....' : newResults[index].device.name),
                                    subtitle: Text(
                                      newResults[index].device.id.id,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        disconnect = false;
                                        connectDevice = newResults[index].device;
                                      });
                                    },
                                  ),
                                );
                              },
                              itemCount: newResults.length,
                            ),
                          ),
                        ],
                      );
                    });
              }),
        ],
      ),
    );
  }
}
