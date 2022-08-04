import 'package:flutter/cupertino.dart';

class LoadingProvider extends ChangeNotifier {
  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
