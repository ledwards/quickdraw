import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/SwCard.dart';
import 'models/SwDecklist.dart';
import 'models/SwStack.dart';
import 'models/SwDeck.dart';

import 'controllers/Loader.dart';
import 'controllers/Wizard.dart';
import 'controllers/WizardStep.dart';

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
  Wizard get wizard => Provider.of<Wizard>(context, listen: false);
  SwDeck get currentDeck => Provider.of<SwDeck>(context, listen: false);
  Metagame meta = Metagame(null);
  SwStack get currentStack => wizard.currentStack;
  set currentStack(SwStack s) => wizard.currentStack.refresh(s);

  Function _setupForStep(int i) => wizard.steps[i].setup();
  void nextStep() => wizard.nextStep();
  void clearCallbacks() => wizard.clearCallbacks(currentDeck);
  void addStepListener() => wizard.addCurrentStepListener(currentDeck);

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
      meta.allCards = SwStack(loadedCards, 'All Cards');
      meta.allDecklists = loadedDecklists;
      meta.allArchetypes = results[0];
      currentStack = SwStack.fromStack(results[1], 'Choose A Side');
    });

    _stepOne().setup();
    _attachListeners();
  }

  _attachListeners() {
    wizard.addListener(() {
      int step = wizard.stepNumber;
      clearCallbacks();
      setState(() => _setupForStep(step));
    });

    currentDeck.addListener(() {
      int length = currentDeck.length;
      List<SwCard> justAddedCards =
          currentDeck.sublist(wizard.deckCursor, length);
      wizard.deckCursor = length;

      setState(() {
        for (SwCard card in justAddedCards) {
          _showCardAddedNotif(card);
          print("Added: ${card.title}");
        }
      });
    });
  }

  _showCardAddedNotif(card) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        duration: Duration(milliseconds: 600),
        content: new Text(
          "Added ${card.title}",
          style: TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          title: Text(currentStack == null ? 'Loading...' : currentStack.title),
        ),
        drawer: wizard.stepNumber == 1 ? null : QuickDrawer(),
        body: wizard.stepNumber == 1
            ? CardBackPicker(_stepOne().callback)
            : SwipeableStack(
                stack: currentStack,
                deck: currentDeck,
                maybe: wizard.sideStacks['maybe'],
                trash: wizard.sideStacks['trash'],
                step: wizard.stepNumber,
              ));
  }

  WizardStep _stepOne() {
    return WizardStep(wizard, () {
      print('Step: 1');
    }, (side) {
      print("Picked $side Side");
      setState(() {
        currentDeck.side = side;
        wizard.setup(side, meta, currentDeck);
      });
    });
  }
}
