import 'package:flutter/widgets.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : _step = 1,
        cursor = 0;

  int _step;
  int cursor;

  int get step => _step;

  set step(int value) {
    _step = value;
    notifyListeners();
  }

  void next() {
    step += 1;
  }
}
