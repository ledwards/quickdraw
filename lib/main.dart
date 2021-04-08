import 'dart:convert' show json;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'models/SwCard.dart';
import 'models/SwDecklist.dart';
import 'models/SwStack.dart';
import 'models/SwDeck.dart';
import 'models/SwArchetype.dart';

import 'controllers/Wizard.dart';
import 'controllers/WizardStep.dart';

import 'rules/Objectives.dart';
import 'rules/StartingInterrupts.dart';

import 'widgets/SwipeableStack.dart';
import 'widgets/QuickDrawer.dart';
import 'widgets/CardBackPicker.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Wizard()),
        ChangeNotifierProvider(create: (_) => SwDeck('New Deck')),
        ChangeNotifierProvider(create: (_) => SwStack([], 'New Deck')),
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
      title: 'SW:CCG Builder',
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
  // TODO: Belongs in a Metagame or Library class?
  SwStack _allCards;
  List<SwDecklist> _allDecklists = [];
  List<SwArchetype> _allArchetypes = [];

  // TODO: a class to hold a HashMap of Stacks that are swapped in and out during deckbuilding
  SwStack _maybeStack;

  Wizard get _wizard => Provider.of<Wizard>(context, listen: false);
  String get _currentSide => _wizard.currentSide;
  SwDeck get _currentDeck => Provider.of<SwDeck>(context, listen: false);
  SwStack get _currentStack => _wizard.currentStack;
  set _currentStack(SwStack s) => _wizard.currentStack = s;
  List<SwStack> get _futureStacks => _wizard.futureStacks;
  Function _callbackForStep(int i) => _wizard.steps[i].callback;
  Function _setupForStep(int i) => _wizard.steps[i].setup();

  void nextStep() => context.read<Wizard>().next();
  void clearCallbacks() => _currentDeck.removeListener(_wizard.currentCallback);
  void addStepListener() {
    _wizard.currentCallback = _callbackForStep(_wizard.step);
    _currentDeck.addListener(_wizard.currentCallback);
  }

  @override
  void initState() {
    _setup();
    super.initState();
  }

  _setup() async {
    List<SwCard> loadedCards;
    List<SwDecklist> loadedDecklists;

    List results =
        await Future.wait([_loadCards(), _loadDecklists()]).then((res) {
      loadedCards = res[0];
      loadedDecklists = res[1];

      return [
        _loadArchetypes(loadedDecklists, loadedCards),
        SwStack(loadedCards, 'All Cards'),
      ];
    });

    // TODO: Is async necessary?
    setState(() {
      this._allCards = new SwStack(loadedCards, 'All Cards');
      this._allDecklists = loadedDecklists;
      this._allArchetypes = results[0];
      this._currentStack = new SwStack.fromStack(results[1], 'Choose A Side');
      this._maybeStack = new SwStack([], 'Maybe Cards');
    });

    _buildSteps();
    _attachListeners();
    _setupForStep(1);
  }

  Future<List<SwCard>> _loadCards() async {
    List<SwCard> cards = [];

    for (String f in ['data/cards/Light.json', 'data/cards/Dark.json']) {
      await rootBundle.loadString(f).then((data) {
        final cardsData = json.decode(data);
        cards.addAll(SwCard.listFromJson(cardsData['cards']));
      });
    }
    return cards;
  }

  Future<List<SwDecklist>> _loadDecklists() async {
    List<SwDecklist> decklists = [];

    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final filenames = manifestMap.keys
        .where((key) => key.contains('data/decklists/'))
        .toList();

    for (String f in filenames) {
      await rootBundle.loadString(f).then((String data) {
        final deckTitle = json.decode(data).keys.toList()[0];
        final deckJson = json.decode(data).values.toList()[0];
        decklists.add(SwDecklist.fromJson(deckJson, deckTitle));
      });
    }
    return decklists;
  }

  List<SwArchetype> _loadArchetypes(
      List<SwDecklist> decklists, List<SwCard> library) {
    List<SwArchetype> archetypes = [];

    for (SwDecklist d in decklists) {
      SwArchetype archetype = archetypes
          .firstWhere((a) => a.title == d.archetypeName, orElse: () => null);

      if (archetype == null) {
        SwArchetype newArchetype = new SwArchetype.fromDecklist(d, library);
        archetypes.add(newArchetype);
      } else {
        archetype.decklists.add(d);
      }
    }
    return archetypes;
  }

  _attachListeners() {
    _wizard.addListener(() {
      int step = _wizard.step;
      print("Step: $step");
      clearCallbacks();
      _setupForStep(step);
    });

    _currentDeck.addListener(() {
      int length = _currentDeck.length;
      List<SwCard> newCards = _currentDeck.sublist(_wizard.deckCursor, length);
      _wizard.deckCursor = length;

      for (SwCard card in newCards) {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
            duration: Duration(milliseconds: 500),
            content: new Text(
              "Added ${card.title}",
              style: TextStyle(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            )));
        print("Added: ${card.title}");
      }
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
    } else if (_wizard.step == 1) {
      // Pick A Side
      body = CardBackPicker(_callbackForStep(1));
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

  _buildSteps() {
    Map<int, WizardStep> _steps = {
      1: WizardStep(() {
        print('Step: 1');
      }, (side) {
        print("Picked $side Side");
        setState(() {
          _allCards = _allCards.bySide(side);
          _wizard.currentSide = side;
          nextStep();
        });
      }),
      2: WizardStep(() {
        print(_currentSide);
        List<SwArchetype> allPossibleArchetypes =
            _allArchetypes.where((a) => a.side == _currentSide).toList();
        SwStack objectives = _allCards.byType('Objective');
        SwStack startingLocations = new SwStack(
          allPossibleArchetypes.map((a) => a.startingCard).toSet().toList(),
          'Starting Locations',
        ).bySide(_currentSide).byType('Location');

        setState(() {
          _currentStack = objectives.concat(startingLocations);
          _currentStack.title = 'Objectives & Starting Locations';
        });
        addStepListener();
      }, () {
        nextStep();
      }),
      3: WizardStep(() {
        SwCard startingCard = _currentDeck.startingCard();

        if (startingCard.type == 'Objective') {
          Map<String, dynamic> pulled =
              pullByObjective(startingCard, _allCards);
          setState(() {
            _currentDeck.addStack(pulled['mandatory']);
            _futureStacks.addAll(pulled['optionals']);
          });
        }

        if (startingCard.type == 'Objective' && _futureStacks.isNotEmpty) {
          setState(() {
            _currentStack.clear();
            _currentStack.title = _futureStacks[0].title;
            _currentStack.addStack(_futureStacks.removeAt(0));
          });
          addStepListener();
        } else {
          nextStep(); // Objective is only pulling mandatory cards or is a Location
        }
      }, () {
        if (_futureStacks.isEmpty) {
          nextStep();
        } else {
          setState(() {
            _currentStack = _futureStacks.removeAt(0);
          });
        }
      }),
      4: WizardStep(() {
        SwStack startingInterrupts =
            _allCards.byType('Interrupt').matchesSubType('Starting');

        setState(() {
          _currentStack = startingInterrupts;
          _currentStack.title = 'Starting Interrupt';
        });
        addStepListener();
      }, () {
        nextStep();
      }),
      5: WizardStep(() {
        SwCard startingInterrupt = _currentDeck.startingInterrupt();

        if (startingInterrupt != null) {
          Map<String, dynamic> pulled =
              pullByStartingInterrupt(startingInterrupt, _allCards);
          setState(() {
            _currentDeck.addStack(pulled['mandatory']);
            _futureStacks.addAll(pulled['optionals']);
          });
        } else {
          nextStep();
        }

        if (startingInterrupt != null && _futureStacks.isNotEmpty) {
          setState(() {
            _currentStack.clear();
            _currentStack.title = _futureStacks[0].title;
            _currentStack.addStack(_futureStacks.removeAt(0));
          });
          addStepListener();
        } else {
          nextStep(); // Starting Interrupt is only pulling mandatory cards
        }
      }, () {
        SwCard startingInterrupt = _currentDeck.startingInterrupt();
        SwCard lastCard = _currentDeck.lastCard();

        _handleSpecialPuller(startingInterrupt, lastCard);

        if (_futureStacks.isEmpty) {
          nextStep();
        } else {
          setState(() {
            _currentStack = _futureStacks.removeAt(0);
          });
        }
      }),
      6: WizardStep(() {
        return null;
      }, () {
        return null;
      }),
      7: WizardStep(() {
        return null;
      }, () {
        return null;
      }),
      8: WizardStep(() {
        return null;
      }, () {
        return null;
      }),
    };

    setState(() {
      _wizard.steps = _steps;
    });
  }

  _handleSpecialPuller(SwCard startingInterrupt, SwCard lastCard) {
    switch (startingInterrupt.title) {
      case 'Any Methods Necessary':
        if (lastCard.type == 'Character') {
          if (_allCards.matchingWeapons(lastCard).isNotEmpty()) {
            SwStack matchingWeapons = _allCards.matchingWeapons(lastCard);
            matchingWeapons.title = '(Optional) Matching Weapon';
            _futureStacks.add(matchingWeapons);
          }
          if (_allCards.matchingStarships(lastCard).isNotEmpty()) {
            SwStack matchingStarships = _allCards.matchingStarships(lastCard);
            matchingStarships.title = '(Optional) Matching Starship';
            _futureStacks.add(matchingStarships);
          }
        } else if (lastCard.title == 'Cloud City: Security Tower (V)') {
          SwStack despairs =
              _allCards.findAllByNames(['Despair (V)', 'Despair']);
          despairs.title = '(Optional) Despair';
          _futureStacks.insert(0, despairs);
        }
        break;
    }
  }
}
