import 'package:flutter/widgets.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : step = 1,
        cursor = 0;

  int step;
  int cursor;

  void next() {
    step += 1;
    notifyListeners();
  }
}
