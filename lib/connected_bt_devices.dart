import 'package:flowprotest/device_services_page.dart';
import 'package:flowprotest/model/providers/loading_provider.dart';
import 'package:flowprotest/scan_bt_devices.dart';
import 'package:flowprotest/select_bt_device.dart';
import 'package:flowprotest/single_reader_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'model/providers/type_with_notify.dart';

class ConnectedBtDevices extends StatefulWidget {
  const ConnectedBtDevices({Key? key}) : super(key: key);

  @override
  State<ConnectedBtDevices> createState() => _ConnectedBtDevicesState();
}

class _ConnectedBtDevicesState extends State<ConnectedBtDevices> {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Connected Devices')),
      body: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),
          SizedBox(
            height: 80,
            child: Image.asset('assets/logo/logo_light.png'),
          ),
          const SizedBox(
            height: 10,
            width: double.infinity,
          ),
          ElevatedButton(
              onPressed: () {
                // context.read<BoolsWithNotify>().setValue(0, true);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanBtDevices(),
                    )).then((value) {
                  context.read<LoadingProvider>().setLoading(false);

                  setState(() {});
                });
              },
              child: const Text('Connect Devices')),
          FutureBuilder<List<BluetoothDevice>>(
              future: flutterBlue.connectedDevices,
              builder: (context, snapshot) {
                print('Devices: ${snapshot.data?.map((e) => e.name)}');
                if (snapshot.hasData) {
                  if (snapshot.data!.length == 0) {
                    return Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(height: 90),
                        Icon(Icons.no_cell_rounded, color: Colors.white30, size: 80),
                        SizedBox(height: 40),
                        Text('No devices connected'),
                        SizedBox(height: 10),
                      ],
                    ));
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, i) {
                        // print('${snapshot.data![i].name}');
                        return Card(
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data![i].name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      snapshot.data![i].id.id,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      snapshot.data![i].type.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              )),
                              IconButton(
                                onPressed: () async {
                                  List<BluetoothService> services = await snapshot.data![i].discoverServices();

                                  if (mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SingleReaderPage(title: snapshot.data![i].name, services: services)));
                                  }
                                },
                                icon: const Icon(Icons.insert_chart_outlined_rounded),
                                color: Colors.blue,
                              ),
                              IconButton(
                                onPressed: () async {
                                  List<BluetoothService> services = await snapshot.data![i].discoverServices();
                                  if (mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DeviceServicesPage(services: services)));
                                  }
                                },
                                icon: const Icon(Icons.settings),
                                color: Colors.blue,
                              ),
                              IconButton(
                                onPressed: () async {
                                  await snapshot.data![i].disconnect();
                                  await Future.delayed(const Duration(milliseconds: 100));
                                  setState(() {});
                                },
                                icon: const Icon(Icons.link_off),
                                color: Colors.red,
                              ),
                              IconButton(
                                onPressed: () async {
                                  // await snapshot.data![i].requestMtu(512);
                                  int mtu = await snapshot.data![i].mtu.first;
                                  print(mtu);
                                },
                                icon: const Icon(Icons.text_snippet),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        );
                      });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ],
      ),
    );
  }
}
