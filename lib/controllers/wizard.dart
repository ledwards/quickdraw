import 'package:flutter/widgets.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : _step = 1,
        steps = {},
        deckCursor = 0,
        currentCallback = null,
        currentStack = null,
        futureStacks = [],
        currentSide = null;

  int _step; // TODO: distinguish between step = WizardStep obj and stepNumber
  Map<int, WizardStep> steps;
  int deckCursor;
  Function currentCallback;
  SwStack currentStack;
  List<SwStack> futureStacks;
  String currentSide;

  int get step => _step;
  WizardStep get currentWizardStep => steps[step];

  set step(int value) {
    _step = value;
    notifyListeners();
  }

  void nextStep() {
    step += 1;
  }

  void addCurrentStepListener(Listenable target) {
    currentCallback = currentWizardStep.callback;
    target.addListener(currentCallback);
  }
}
