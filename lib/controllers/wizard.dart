import 'package:flutter/widgets.dart';
import '../models/SwStack.dart';
import '../models/SwDeck.dart';
import '../rules/Metagame.dart';
import 'WizardStep.dart';
import 'WizardStep2ChooseObjective.dart';
import 'WizardStep3PulledByObjective.dart';
import 'WizardStep4ChooseStartingInterrupt.dart';
import 'WizardStep5PulledByStartingInterrupt.dart';
// import 'WizardStep6MainDeck.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : meta = Metagame(null),
        _stepNumber = 1,
        steps = {},
        deckCursor = 0,
        currentStack = SwStack([], 'Pick a Side'),
        futureStacks = [],
        sideStacks = {
          'maybe': SwStack([], '"Maybe" Cards'),
          'trash': SwStack([], 'Trash'),
        };

  Metagame meta;
  int _stepNumber;
  Map<int, WizardStep> steps;
  int deckCursor;
  Function currentCallback;
  SwStack currentStack;
  List<SwStack> futureStacks;
  Map<String, SwStack> sideStacks;

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

  void setup(String side, Metagame metagame, SwDeck deck) {
    meta = metagame;
    meta.side = side;
    buildSteps(deck);
    nextStep();
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

  void buildSteps(SwDeck deck) {
    steps = {
      2: pickObjectiveStep(this, meta, deck),
      3: pulledByObjective(this, meta, deck),
      4: pickStartingInterrupt(this, meta, deck),
      5: pulledByStartingInterrupt(this, meta, deck),
      6: WizardStep(this, () {
        return null;
      }, () {
        return null;
      }),
      7: WizardStep(this, () {
        return null;
      }, () {
        return null;
      }),
      8: WizardStep(this, () {
        return null;
      }, () {
        return null;
      }),
    };
  }
}
