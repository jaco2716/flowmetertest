import 'package:flowprotest/home_page.dart';
import 'package:flowprotest/select_bt_device.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
        body: SelectBtDevice(),
      ),
    );
  }
}
