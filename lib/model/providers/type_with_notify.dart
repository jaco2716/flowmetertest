import 'package:flutter/foundation.dart';

class IntsWithNotify extends ChangeNotifier {
  final List<int> _ints;
  IntsWithNotify(this._ints);
  List<int> get ints => _ints;

  void setValue(int setIndex, int value) {
    _ints[setIndex] = value;
    notifyListeners();
  }
}

class BoolsWithNotify extends ChangeNotifier {
  final List<bool> _bools;
  BoolsWithNotify(this._bools);
  List<bool> get bools => _bools;

  void setValue(int setIndex, bool value) {
    _bools[setIndex] = value;
    notifyListeners();
  }
}

class DateTimesWithNotify extends ChangeNotifier {
  final List<DateTime> _dateTimes;
  DateTimesWithNotify(this._dateTimes);
  List<DateTime> get dateTimes => _dateTimes;

  void setValue(int setIndex, DateTime value) {
    _dateTimes[setIndex] = value;
    notifyListeners();
  }
}
