import 'dart:convert' show json;
import 'dart:math' show pi;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:provider/provider.dart';
import 'package:swccg_builder/objectives.dart';

import 'models/sw_card.dart';
import 'models/sw_decklist.dart';
import 'models/sw_stack.dart';
import 'models/sw_deck.dart';
import 'models/sw_archetype.dart';
import 'wizard.dart';
import 'starting_interrupts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Wizard()),
        ChangeNotifierProvider(create: (_) => SwDeck(null, 'New Deck')),
        ChangeNotifierProvider(
            create: (_) => SwStack(null, [], 'Choose a Side')),
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
        primarySwatch: Colors.blue,
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

  // TODO: currentStack gets  anotifier
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
  void _currentDeckAdd(SwCard card) => context.read<SwDeck>().add(card);
  void _currentDeckAddStack(SwStack stack) =>
      context.read<SwDeck>().addStack(stack);
  void _currentDeckRemoveListener(Function f) =>
      context.read<SwDeck>().removeListener(f);

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
        SwStack.fromCards(side, loadedCards, "Default"),
      ];
    });

    setState(() {
      this._allCards = new SwStack.fromCards(side, loadedCards, 'All Cards');
      this._allDecklists = loadedDecklists;
      this._allArchetypes = results[0];
      this._currentStack = results[1];
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
            duration: Duration(seconds: 1),
            content: new Text(
              "Added: ${card.title}",
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

    if (_currentStack == null) {
      w = new Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          title: Text('Loading...'),
        ),
      );
    } else {
      // Wizard Entry
      switch (context.watch<Wizard>().step) {
        case 1: // Side
          w = Scaffold(
            appBar: AppBar(
              title: Text(context.watch<SwStack>().title),
              backgroundColor: Colors.transparent,
            ),
            drawer: _drawerWidget(context),
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

        case 2: // Objective or Starting Location
          // TODO: If stack ends up empty, refresh it
          w = Scaffold(
            key: UniqueKey(),
            appBar: AppBar(
              title: Text("${_currentDeck().title} (${_currentDeck().length})"),
              backgroundColor: Colors.transparent,
            ),
            drawer: _drawerWidget(context),
            body: _swipeableStack(context),
          );
          break;

        case 3: // Pulled by Objective
          // TODO: If stack ends up empty, refresh it
          w = Scaffold(
            key: UniqueKey(),
            appBar: AppBar(
              title: Text("${_currentDeck().title} (${_currentDeck().length})"),
              backgroundColor: Colors.transparent,
            ),
            drawer: _drawerWidget(context),
            body: _swipeableStack(context),
          );
          break;

        case 4: // Starting Interrupt
          // TODO: If stack ends up empty, refresh it
          w = Scaffold(
            key: UniqueKey(),
            appBar: AppBar(
              title: Text("${_currentDeck().title} (${_currentDeck().length})"),
              backgroundColor: Colors.transparent,
            ),
            drawer: _drawerWidget(context),
            body: _swipeableStack(context),
          );
          break;

        case 6: // Main Deck
          w = Scaffold(
            key: UniqueKey(),
            appBar: AppBar(
              title: Text("${_currentDeck().title} (${_currentDeck().length})"),
              backgroundColor: Colors.transparent,
            ),
            drawer: _drawerWidget(context),
            body: _swipeableStack(context),
          );
          break;
      }
    }
    return w;
  }

  Widget _swipeableStack(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Text(
              "${_currentStack.title} (${_currentStack.length})",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: TinderSwapCard(
              swipeUp: true,
              swipeDown: true,
              orientation: AmassOrientation.TOP,
              totalNum: _currentStack.length,
              stackNum: 12,
              swipeEdge: 4.0,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.width * 0.9,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.width * 0.8,
              cardBuilder: _cardBuilder,
              cardController: CardController(),
              swipeUpdateCallback:
                  (DragUpdateDetails details, Alignment align) {
                if (align.x.abs() > align.y.abs()) {
                  if (align.x < 0) {
                    print("left swipe");
                  } else if (align.x > 0) {
                    print("right swipe");
                  }
                } else if (align.x.abs() < align.y.abs()) {
                  if (align.y < 0) {
                    print("up swipe");
                  } else if (align.y > 0) {
                    print("down swipe");
                  }
                }
              },
              swipeCompleteCallback:
                  (CardSwipeOrientation orientation, int index) {
                setState(() {
                  SwCard swipedCard = this._currentStack.removeAt(index);
                  switch (orientation) {
                    case CardSwipeOrientation.LEFT:
                      break;
                    case CardSwipeOrientation.RIGHT:
                      _currentStack.add(swipedCard);
                      break;
                    case CardSwipeOrientation.UP:
                      _currentDeck().add(swipedCard);
                      break;
                    case CardSwipeOrientation.DOWN:
                      _maybeStack.add(swipedCard);
                      break;
                    case CardSwipeOrientation.RECOVER:
                      _currentStack.insert(index, swipedCard);
                      break;
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _drawerItem(context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // need a callback, or simply call _stepX() method
        Navigator.pop(context); // close the drawer
      },
    );
  }

  List<Widget> _drawerWidgets(context) {
    // TODO: Refresh any state to initial state if you go back to an earlier step
    return [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Text(
          'Create Deck',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      _drawerItem(context, 'Side', Icons.filter_1),
      _drawerItem(context, 'Objective', Icons.filter_2),
      _drawerItem(context, 'Pulled by Objective',
          Icons.subdirectory_arrow_right_rounded),
      _drawerItem(context, 'Starting Interrupt', Icons.filter_3),
      _drawerItem(context, 'Pulled By Starting Interrupt',
          Icons.subdirectory_arrow_right_rounded),
      _drawerItem(context, 'Main Deck', Icons.filter_4),
      _drawerItem(context, 'Starting Effect', Icons.filter_5),
      _drawerItem(
          context, 'Defensive Shields', Icons.subdirectory_arrow_right_rounded),
    ];
  }

  Widget _drawerWidget(context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: _drawerWidgets(context),
      ),
    );
  }

  Widget _cardBuilder(context, index) {
    return Card(
      child: Transform(
          alignment: Alignment.center,
          transform: _currentStack[0].subType != 'Site'
              ? (_currentStack[index].subType == 'Site') // all vertical
                  ? Matrix4.rotationZ(-pi / 2)
                  : Matrix4.rotationZ(0)
              : (_currentStack[index].subType == 'Site') // all horizontal
                  ? Matrix4.rotationZ(0)
                  : Matrix4.rotationZ(_currentSide() == 'Light'
                      ? -pi / 2
                      : pi / 2), // according to side
          child: Image.network(
            _currentStack[index].imageUrl,
            alignment: Alignment.center,
          )),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
    );
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
    print('executing step3 callback');
    if (_futureStacks.isEmpty) {
      _nextStep();
    } else {
      setState(() {
        _currentStack = _futureStacks.removeAt(0);
      });
    }
  }

  _setupStep(int s) {
    String side = _currentSide();

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
        _currentDeck().removeListener(_step2Callback);

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
        _currentDeck().removeListener(_step3Callback);

        SwStack startingInterrupts = _allCards
            .bySide(_currentSide())
            .byType('Interrupt')
            .matchesSubType('Starting');

        setState(() {
          this._currentStack = startingInterrupts;
          this._currentStack.title = 'Starting Interrupts';
        });
        break;

      case 6: // Cards deployed by Starting Interrupts
        break;
    }
  }
}
