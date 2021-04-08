import 'package:flutter/widgets.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : _step = 1,
        deckCursor = 0,
        steps = {},
        currentCallback = null,
        currentStack = null,
        futureStacks = [],
        currentSide = null;

  int _step;
  int deckCursor;
  Map<int, WizardStep> steps;
  Function currentCallback;
  SwStack currentStack;
  List<SwStack> futureStacks;
  String currentSide;

  int get step => _step;

  set step(int value) {
    _step = value;
    notifyListeners();
  }

  void next() {
    step += 1;
  }
}
