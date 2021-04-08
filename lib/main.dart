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

import 'rules/Objectives.dart';
import 'rules/StartingInterrupts.dart';

import 'widgets/SwipeableStack.dart';
import 'widgets/QuickDrawer.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Wizard()),
        ChangeNotifierProvider(create: (_) => SwDeck(null, 'New Deck')),
        ChangeNotifierProvider(
            create: (_) => SwStack(null, [], 'Choose A Side')),
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

  // TODO: currentStack gets a notifier
  SwStack _currentStack;
  List<SwStack> _futureStacks = [];

  // TODO: a class to hold a HashMap of Stacks that are swapped in and out during deckbuilding
  SwStack _maybeStack;

  // Accessors
  SwDeck _currentDeck() => Provider.of<SwDeck>(context, listen: false);
  String _currentSide() => _currentDeck().side;
  Wizard _wizard() => Provider.of<Wizard>(context, listen: false);
  int _currentStep() => _wizard().step;

  // Mutators
  void _nextStep() => context.read<Wizard>().next();
  void _currentDeckAddStack(SwStack stack) =>
      context.read<SwDeck>().addStack(stack);

  _setup() async {
    String side = _currentSide();
    List<SwCard> loadedCards;
    List<SwDecklist> loadedDecklists;

    List results =
        await Future.wait([_loadCards(), _loadDecklists()]).then((res) {
      loadedCards = res[0];
      loadedDecklists = res[1];

      return [
        _loadArchetypes(loadedDecklists, loadedCards),
        SwStack.fromCards(side, loadedCards, 'All Cards'),
      ];
    });

    // TODO: Audit this to make sure the flow is as simple as possible. (async?)
    setState(() {
      this._allCards = new SwStack.fromCards(side, loadedCards, 'All Cards');
      this._allDecklists = loadedDecklists;
      this._allArchetypes = results[0];
      this._currentStack =
          new SwStack.fromCards(side, results[1].cards, 'Choose A Side');
      this._maybeStack = new SwStack(side, [], 'Maybe Cards');
    });

    _wizard().addListener(() {
      int step = _wizard().step;
      print("Step: $step");
      _setupStep(step);
    });

    _currentDeck().addListener(() {
      int cursor = _wizard().cursor;
      int length = _currentDeck().length;
      List<SwCard> newCards = _currentDeck().sublist(cursor, length);
      _wizard().cursor = length;

      for (SwCard card in newCards) {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
            duration: Duration(milliseconds: 500),
            content: new Text(
              "Added ${card.title}",
              textAlign: TextAlign.center,
            )));
        print("Added a card to deck: ${card.title}");
      }
    });
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

  @override
  void initState() {
    _setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget w;

    // switch should be inside body
    if (_currentStack == null) {
      w = new Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(
            child: Image.network(
                'https://res.starwarsccg.org/cardlists/images/starwars/Virtual4-Light/large/quickdraw.gif')),
      );
    } else {
      switch (context.watch<Wizard>().step) {
        case 1: // Side
          w = Scaffold(
            appBar: AppBar(
              title: Text(_currentStack.title),
            ),
            drawer: QuickDrawer(),
            body: Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    _cardBackWidget(
                      context,
                      'Dark',
                      _step1Callback,
                    ),
                    _cardBackWidget(
                      context,
                      'Light',
                      _step1Callback,
                    ),
                  ],
                ),
              ),
            ),
          );
          break;

        default: // Objective or Starting Location
          // TODO: If stack ends up empty, refresh it
          w = Scaffold(
            key: UniqueKey(),
            appBar: AppBar(
              title: Text(_currentStack.title),
            ),
            drawer: QuickDrawer(),
            body: SwipeableStack(stack: _currentStack, deck: _currentDeck()),
          );
          break;
      }
    }
    return w;
  }

  Widget _cardBackWidget(context, String side, Function callback) {
    return Expanded(
      child: new GestureDetector(
        onTap: () => callback(side),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Image(
              image: AssetImage(
                  "assets/images/${side == 'Dark' ? 'ds' : 'ls'}-back.jpg")),
        ),
      ),
    );
  }

  _step1Callback(String side) {
    setState(() {
      this._allCards = _allCards.bySide(side);
      _currentDeck().side = side;
      _nextStep();
    });
  }

  _step2Callback() {
    _nextStep();
  }

  _step3Callback() {
    if (_futureStacks.isEmpty) {
      _nextStep();
    } else {
      setState(() {
        _currentStack = _futureStacks.removeAt(0);
      });
    }
  }

  _step4Callback() {
    _nextStep();
  }

  _step5Callback() {
    SwCard startingInterrupt = _currentDeck().startingInterrupt();
    SwCard lastCard = _currentDeck().lastCard();

    // handle Starting Interrupts whose choices have logic
    // TODO: refactor into starting_interrupts.dart
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

    if (_futureStacks.isEmpty) {
      _nextStep();
    } else {
      setState(() {
        _currentStack = _futureStacks.removeAt(0);
      });
    }
  }

  _step6Callback() {
    // maybe only move to next step on some button press?
  }

  _setupStep(int s) {
    String side = _currentSide();
    _currentDeck().removeListener(_step2Callback);
    _currentDeck().removeListener(_step3Callback);
    _currentDeck().removeListener(_step4Callback);
    _currentDeck().removeListener(_step5Callback);
    _currentDeck().removeListener(_step6Callback);
    // _currentDeck().removeListener(_step7Callback);

    switch (s) {
      case 1: // Pick a Side
        break;

      case 2: // Pick an Objective or Starting Location
        List<SwArchetype> allPossibleArchetypes =
            _allArchetypes.where((a) => a.side == side).toList();
        SwStack objectives = _allCards.byType('Objective');
        SwStack startingLocations = new SwStack.fromCards(
          side,
          allPossibleArchetypes.map((a) => a.startingCard).toSet().toList(),
          'Starting Locations',
        ).bySide(side).byType('Location');

        setState(() {
          this._currentStack = objectives.concat(startingLocations);
          this._currentStack.title = 'Objectives & Starting Locations';
        });

        _currentDeck().addListener(_step2Callback);
        break;

      case 3: // Pulled by Objective
        SwCard startingCard = _currentDeck().startingCard();

        if (startingCard.type == 'Objective') {
          Map<String, dynamic> pulled =
              pullByObjective(startingCard, _allCards);
          setState(() {
            _currentDeckAddStack(pulled['mandatory']);
            _futureStacks.addAll(pulled['optionals']);
          });
        }

        if (startingCard.type == 'Objective' && _futureStacks.isNotEmpty) {
          setState(() {
            _currentStack.clear();
            _currentStack.title = _futureStacks[0].title;
            _currentStack.addStack(_futureStacks.removeAt(0));
          });
          _currentDeck().addListener(_step3Callback);
        } else {
          _nextStep(); // Objective is only pulling mandatory cards or is a Location
        }
        break;

      case 4: // Pick a Starting Interrupt
        SwStack startingInterrupts =
            _allCards.byType('Interrupt').matchesSubType('Starting');

        setState(() {
          this._currentStack = startingInterrupts;
          this._currentStack.title = 'Starting Interrupt';
        });
        _currentDeck().addListener(_step4Callback);
        break;

      case 5: // Pulled by Starting Interrupts
        SwCard startingInterrupt = _currentDeck().startingInterrupt();

        if (startingInterrupt != null) {
          Map<String, dynamic> pulled =
              pullByStartingInterrupt(startingInterrupt, _allCards);
          setState(() {
            _currentDeckAddStack(pulled['mandatory']);
            _futureStacks.addAll(pulled['optionals']);
          });
        } else {
          _nextStep();
        }

        if (startingInterrupt != null && _futureStacks.isNotEmpty) {
          setState(() {
            _currentStack.clear();
            _currentStack.title = _futureStacks[0].title;
            _currentStack.addStack(_futureStacks.removeAt(0));
          });
          _currentDeck().addListener(_step5Callback);
        } else {
          _nextStep(); // Starting Interrupt is only pulling mandatory cards
        }
        break;

      case 6: // Main Deck
        break;

      case 7: // Starting Effect
        break;

      case 8: // Defensive Shields
        break;
    }
  }
}
