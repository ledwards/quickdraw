import 'package:flutter/widgets.dart';
import 'WizardStep.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : _step = 1,
        cursor = 0,
        steps = {};

  int _step;
  int cursor;
  Map<int, WizardStep> steps;

  int get step => _step;

  set step(int value) {
    _step = value;
    notifyListeners();
  }

  void next() {
    step += 1;
  }
}
