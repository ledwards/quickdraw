import 'package:flutter/foundation.dart';
import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwArchetype.dart';

// requires: archetypes, library, deck
WizardStep pickObjectiveStep(Wizard wizard, Map<String, dynamic> data) {
  return WizardStep(wizard, () {
    List<SwArchetype> allPossibleArchetypes =
        data['archetypes'].where((a) => a.side == wizard.currentSide).toList();
    SwStack objectives = data['library'].byType('Objective');
    SwStack startingLocations = new SwStack(
      allPossibleArchetypes.map((a) => a.startingCard).toSet().toList(),
      'Starting Locations',
    ).bySide(wizard.currentSide).byType('Location');

    // setState(() {
    //   _currentStack = objectives.concat(startingLocations);
    //   _currentStack.title = 'Objectives & Starting Locations';
    // });

    wizard.addCurrentStepListener(data['deck']);
  }, () {
    wizard.nextStep();
  });
}
