import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ByteDataProvider extends ChangeNotifier {
  BluetoothCharacteristic characteristic;
  List<int>? characteristicData;
  Map<int, List<int>> descriptorData = {};

  ByteDataProvider(this.characteristic);

  void readCharacteristic() async {
    characteristicData = await characteristic.read();
    notifyListeners();
  }

  void readDescriptor(int index) async {
    descriptorData[index] = await characteristic.descriptors[index].read();
    //await Future.delayed(Duration(seconds: 2));
    notifyListeners();
  }
}
