import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/SwCard.dart';
import 'models/SwDecklist.dart';
import 'models/SwStack.dart';
import 'models/SwDeck.dart';
import 'models/SwArchetype.dart';

import 'controllers/Loader.dart';
import 'controllers/Wizard.dart';
import 'controllers/WizardStep.dart';
import 'controllers/WizardStep2ChooseObjective.dart';
import 'controllers/WizardStep3PulledByObjective.dart';
import 'controllers/WizardStep4ChooseStartingInterrupt.dart';
import 'controllers/WizardStep5PulledByStartingInterrupt.dart';
// import 'controllers/WizardStep6MainDeck.dart';

import 'widgets/SwipeableStack.dart';
import 'widgets/QuickDrawer.dart';
import 'widgets/CardBackPicker.dart';

import 'rules/Metagame.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Wizard()),
        ChangeNotifierProvider(create: (_) => SwDeck('New Deck')),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Draw',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  RootPage({Key key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  Metagame meta;

  // TODO: a class to hold a HashMap of Stacks that are swapped in and out during deckbuilding
  SwStack _maybeStack;

  Wizard get _wizard => Provider.of<Wizard>(context, listen: false);
  SwDeck get _currentDeck => Provider.of<SwDeck>(context, listen: false);

  SwStack get _currentStack => _wizard.currentStack;
  set _currentStack(SwStack s) => _wizard.currentStack.refresh(s);
  set _currentSide(String value) {
    print(meta.library.length);
    meta.side = value;
    print(meta.library.length);

    _currentDeck.side = value;
  }

  Function _setupForStep(int i) => _wizard.steps[i].setup();
  void nextStep() => _wizard.nextStep();
  void clearCallbacks() => _wizard.clearCallbacks(_currentDeck);
  void addStepListener() => _wizard.addCurrentStepListener(_currentDeck);

  @override
  void initState() {
    _setup();
    super.initState();
  }

  _setup() async {
    Loader loader = Loader(context);
    List<SwCard> loadedCards;
    List<SwDecklist> loadedDecklists;

    List results =
        await Future.wait([loader.cards(), loader.decklists()]).then((res) {
      loadedCards = res[0];
      loadedDecklists = res[1];

      return [
        loader.archetypes(loadedDecklists, loadedCards),
        SwStack(loadedCards, 'All Cards'),
      ];
    });

    // TODO: Is async necessary?
    setState(() {
      meta = Metagame(null);
      meta.allCards = new SwStack(loadedCards, 'All Cards');
      meta.allDecklists = loadedDecklists;
      meta.allArchetypes = results[0];
      this._currentStack = new SwStack.fromStack(results[1], 'Choose A Side');
      this._maybeStack = new SwStack([], 'Maybe Cards');
    });

    _stepOne().setup();
    _attachListeners();
  }

  // TODO: Do I need listeners here, or just do these things when the values are set?
  _attachListeners() {
    _wizard.addListener(() {
      int step = _wizard.stepNumber;
      print("Step: $step");
      clearCallbacks();
      setState(() => _setupForStep(step));
    });

    _currentDeck.addListener(() {
      setState(() {
        int length = _currentDeck.length;
        List<SwCard> justAddedCards =
            _currentDeck.sublist(_wizard.deckCursor, length);
        _wizard.deckCursor = length;

        for (SwCard card in justAddedCards) {
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
              duration: Duration(milliseconds: 600),
              content: new Text(
                "Added ${card.title}",
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              )));
          print("Added: ${card.title}");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = _currentStack == null ? 'Loading...' : _currentStack.title;
    Widget drawer;
    Widget body;

    if (_currentStack == null) {
      // Loading
      body = Center(
          child: Image.network(
              'https://res.starwarsccg.org/cardlists/images/starwars/Virtual4-Light/large/quickdraw.gif'));
    } else if (_wizard.stepNumber == 1) {
      // Choose A Side
      body = CardBackPicker(_stepOne().callback);
    } else {
      // Stack  Screen
      drawer = QuickDrawer();
      body = SwipeableStack(stack: _currentStack, deck: _currentDeck);
    }

    return Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          title: Text(title),
        ),
        drawer: drawer,
        body: body);
  }

  WizardStep _stepOne() {
    return WizardStep(_wizard, () {
      print('Step: 1');
    }, (side) {
      print("Picked $side Side");
      setState(() {
        _currentSide = side;
        _buildSteps();
        nextStep();
      });
    });
  }

  _buildSteps() {
    Map<int, WizardStep> _steps = {
      2: pickObjectiveStep(_wizard, meta, _currentDeck),
      3: pulledByObjective(_wizard, meta, _currentDeck),
      4: pickStartingInterrupt(_wizard, meta, _currentDeck),
      5: pulledByStartingInterrupt(_wizard, meta, _currentDeck),
      6: WizardStep(_wizard, () {
        return null;
      }, () {
        return null;
      }),
      7: WizardStep(_wizard, () {
        return null;
      }, () {
        return null;
      }),
      8: WizardStep(_wizard, () {
        return null;
      }, () {
        return null;
      }),
    };

    setState(() {
      _wizard.steps = _steps;
    });
  }
}
