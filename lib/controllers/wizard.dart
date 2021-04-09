import 'package:flutter/widgets.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : _step = 1,
        steps = {},
        deckCursor = 0,
        currentCallback = null,
        currentStack = SwStack([], 'Pick a Side'),
        futureStacks = [],
        side = null;

  int _step; // TODO: distinguish between step = WizardStep obj and stepNumber
  Map<int, WizardStep> steps;
  int deckCursor;
  Function currentCallback;
  SwStack currentStack;
  List<SwStack> futureStacks;
  String side;

  int get step => _step;
  WizardStep get currentWizardStep => steps[step];
  bool get isEmpty => steps.isEmpty;

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

  void clearCallbacks(Listenable target) {
    for (WizardStep ws in steps.values.skip(1)) {
      // TODO: move step 1 out of this list
      target.removeListener(ws.callback);
    }
  }
}
