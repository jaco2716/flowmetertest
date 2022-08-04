import 'package:flowprotest/connected_bt_devices.dart';
import 'package:flowprotest/home_page.dart';
import 'package:flowprotest/model/providers/type_with_notify.dart';
import 'package:flowprotest/select_bt_device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/providers/loading_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LoadingProvider>(create: (context) => LoadingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(),
      home: const Scaffold(
        // appBar: AppBar(
        //   title: Text('Demo'),
        // ),
        // body: MyHomePage(),
        body: ConnectedBtDevices(),
      ),
    );
  }
}
