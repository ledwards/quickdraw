import 'package:flutter/widgets.dart';

class Wizard with ChangeNotifier {
  Wizard() : step = 1;

  int step;

  void next() {
    step += 1;
    notifyListeners();
  }
}
