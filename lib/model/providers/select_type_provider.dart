import 'package:flutter/material.dart';

class SelectTypeListProvider extends ChangeNotifier {
  List<SelectType> selectType;
  int indexSelected = 0;
  SelectTypeListProvider(this.selectType);

  void changeSelected(int index) {
    indexSelected = index;
    notifyListeners();
  }

  void updatetest() {
    notifyListeners();
  }
}

class SelectType {
  int id;
  String title;
  SelectType(this.id, this.title);
}
