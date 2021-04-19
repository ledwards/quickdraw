import 'package:flutter/widgets.dart';
import '../models/SwStack.dart';
import '../models/SwDeck.dart';
import '../rules/Metagame.dart';
import 'WizardStep.dart';
import 'WizardStep2ChooseObjective.dart';
import 'WizardStep3PulledByObjective.dart';
import 'WizardStep4ChooseStartingInterrupt.dart';
import 'WizardStep5PulledByStartingInterrupt.dart';
import 'WizardStep6MainDeck.dart';

class Wizard with ChangeNotifier {
  Wizard()
      : meta = Metagame(null),
        _stepNumber = 1,
        steps = {},
        deckCursor = 0,
        currentStack = SwStack([], 'Loading...'),
        futureStacks = [],
        sideStacks = {
          'default': SwStack([], 'Popular'),
          'maybe': SwStack([], '"Maybe" Cards'),
          'allCards': SwStack([], 'All Cards'),
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
  bool get isEmpty => steps.isEmpty;

  int get stepNumber => _stepNumber;
  set stepNumber(int value) {
    _stepNumber = value;
    currentStack.sort();
    notifyListeners();
  }

  bool get starting => stepNumber != 6;

  void nextStep() {
    stepNumber += 1;
  }

  void setup(String side, Metagame metagame, SwDeck deck) {
    this.meta = metagame;
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

  static Map<int, String> get stepNames => {
        1: 'Choose a Side',
        2: 'Choose an Objective',
        3: 'Pulled by Objective',
        4: 'Choose a Starting Interrupt',
        5: 'Pulled by Starting Interrupt',
        6: 'Main Deck',
        7: 'Starting Effect',
        8: 'Defensive Shields'
      };

  void buildSteps(SwDeck deck) {
    steps = {
      2: pickObjectiveStep(this, meta, deck),
      3: pulledByObjective(this, meta, deck),
      4: pickStartingInterrupt(this, meta, deck),
      5: pulledByStartingInterrupt(this, meta, deck),
      6: buildMainDeck(this, meta, deck),
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
