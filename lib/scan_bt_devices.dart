import 'dart:async';

import 'package:flowprotest/model/providers/type_with_notify.dart';
import 'package:flowprotest/widgets/my_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'model/providers/loading_provider.dart';

class ScanBtDevices extends StatefulWidget {
  const ScanBtDevices({Key? key}) : super(key: key);

  @override
  State<ScanBtDevices> createState() => _ScanBtDevicesState();
}

class _ScanBtDevicesState extends State<ScanBtDevices> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  Timer? _timer;

  Future<void> _findPrinters() async {
    // Start scanning

    await flutterBlue.startScan(timeout: const Duration(seconds: 5));
  }

  @override
  void initState() {
    _findPrinters();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BoolsWithNotify>(
      create: (context) => BoolsWithNotify([true]),
      builder: (context, child) {
        initialLoading(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Connect'),
            actions: [
              SizedBox(
                height: 50,
                width: 50,
                child: Consumer<BoolsWithNotify>(
                  builder: (context, value, child) {
                    if (value.bools[0]) {
                      return const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            )),
                      );
                    } else {
                      return IconButton(
                          onPressed: () async {
                            var boolsWithNotify = context.read<BoolsWithNotify>();
                            boolsWithNotify.setValue(0, true);
                            await flutterBlue.stopScan();
                            await Future.delayed(
                                const Duration(
                                  milliseconds: 300,
                                ), () {
                              return _findPrinters();
                            });
                            boolsWithNotify.setValue(0, false);
                          },
                          icon: const Icon(Icons.refresh));
                    }
                  },
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: StreamBuilder<List<ScanResult>>(
                  stream: flutterBlue.scanResults,
                  builder: (context, scanSnapshot) {
                    if (scanSnapshot.hasData) {
                      var scanResults = scanSnapshot.data!.where((element) => element.device.type != BluetoothDeviceType.unknown).toList();
                      scanResults
                          .sort((a, b) => a.device.name.isEmpty ? 1 : a.device.name.compareTo(b.device.name.isEmpty ? 'zzzzz' : b.device.name));

                      return Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child:
                                Text('Select a bluetooth device', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white60)),
                          ),
                          scanResults.isEmpty
                              ? const Center(child: Text('Ingen enheder fundet.'))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: InkWell(
                                        onTap: () async {
                                          var loadingProvider = context.read<LoadingProvider>();
                                          loadingProvider.setLoading(true);
                                          // scanResults[index].device.connect(timeout: const Duration(seconds: 2));

                                          bool? returnValue;
                                          try {
                                            await scanResults[index].device.connect().timeout(const Duration(seconds: 10), onTimeout: () {
                                              debugPrint('timeout occured');
                                              returnValue = false;
                                              scanResults[index].device.disconnect();
                                            }).then((data) {
                                              if (returnValue == null) {
                                                debugPrint('connection successful');
                                                returnValue = true;
                                              }
                                              loadingProvider.setLoading(false);
                                            });
                                          } on PlatformException catch (e) {
                                            loadingProvider.setLoading(false);

                                            if (e.code == 'already_connected') {
                                              showMyDialog(
                                                context,
                                                'Already Connected',
                                                'Device is already connected.',
                                              );
                                            }
                                          }
                                          if (mounted) {
                                            showMyDialog(
                                              context,
                                              returnValue! ? 'Success' : 'Error',
                                              returnValue! ? 'Connection to device made!' : 'Timeout occured, try again.',
                                              infoDialog: !returnValue!,
                                              onlyAction: returnValue!,
                                              myOnPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
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
                                                      scanResults[index].device.name.isEmpty ? '....' : scanResults[index].device.name,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                    ),
                                                    Text(
                                                      scanResults[index].device.id.id,
                                                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Icon(
                                                Icons.link,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 20),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: scanResults.length,
                                ),
                        ],
                      );
                    }
                    // print('scansnapsghot: ${scanSnapshot.data}');
                    else if (scanSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(child: Text('Error'));
                    }
                  },
                ),
              ),
              Consumer<LoadingProvider>(
                builder: (context, value, child) {
                  if (value.isLoading) {
                    return Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator()));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void initialLoading(BuildContext context) async {
    var boolsWithNotify = context.read<BoolsWithNotify>();
    _timer = Timer(const Duration(seconds: 4), () {
      boolsWithNotify.setValue(0, false);
    });
    // Future.delayed(const Duration(seconds: 4), () => boolsWithNotify.setValue(0, false));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
