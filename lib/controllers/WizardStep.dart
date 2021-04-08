class WizardStep {
  WizardStep(setup, callback)
      : setup = setup,
        callback = callback;

  Function setup;
  Function callback;
}
