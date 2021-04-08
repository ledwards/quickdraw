import 'package:flutter/widgets.dart';
import 'WizardStep.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : _step = 1,
        deckCursor = 0,
        steps = {},
        currentCallback = null;

  int _step;
  int deckCursor;
  Map<int, WizardStep> steps;
  Function currentCallback;

  int get step => _step;

  set step(int value) {
    _step = value;
    notifyListeners();
  }

  void next() {
    step += 1;
  }
}
