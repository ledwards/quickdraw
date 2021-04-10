import 'package:flutter/widgets.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : _stepNumber = 1,
        steps = {},
        deckCursor = 0,
        currentCallback = null,
        currentStack = SwStack([], 'Pick a Side'),
        futureStacks = [];

  int _stepNumber; // TODO: distinguish between step = WizardStep obj and stepNumber
  Map<int, WizardStep> steps;
  int deckCursor;
  Function currentCallback;
  SwStack currentStack;
  List<SwStack> futureStacks;

  WizardStep get currentStep => steps[stepNumber];
  int get stepNumber => _stepNumber;
  bool get isEmpty => steps.isEmpty;

  set stepNumber(int value) {
    _stepNumber = value;
    notifyListeners();
  }

  void nextStep() {
    stepNumber += 1;
  }

  void addCurrentStepListener(Listenable target) {
    currentCallback = currentStep.callback;
    target.addListener(currentCallback);
  }

  void clearCallbacks(Listenable target) {
    for (WizardStep ws in steps.values) {
      target.removeListener(ws.callback);
    }
  }
}
