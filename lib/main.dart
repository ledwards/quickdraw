import 'dart:convert' show json;
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tindercard/flutter_tindercard.dart';

import 'sw_card.dart';
import 'sw_decklist.dart';
import 'sw_stack.dart';
import 'sw_deck.dart';
import 'sw_archetype.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  int _currentStep;
  List<SwCard> _allCards = [];
  List<SwDecklist> _allDecklists = [];
  List<SwArchetype> _allArchetypes = [];
  String _currentSide = 'Dark';
  SwStack _currentStack;
  SwStack _maybeStack;
  SwDeck _currentDeck;

  _setup() async {
    List<SwCard> loadedCards;
    List<SwDecklist> loadedDecklists;
    SwStack stack;

    List results =
        await Future.wait([_loadCards(), _loadDecklists()]).then((res) {
      loadedCards = res[0];
      loadedDecklists = res[1];

      // temp
      final decklist = loadedDecklists[0];

      return [
        _loadArchetypes(loadedDecklists, loadedCards),
        _loadStack(decklist.cardNames.getRange(0, 5).toList(), loadedCards,
            decklist.title),
      ];
    });

    setState(() {
      this._currentStep = 1;
      this._allCards = loadedCards;
      this._allDecklists = loadedDecklists;
      this._allArchetypes = results[0];
      this._currentStack = results[1];
      this._maybeStack = new SwStack(_currentSide, [], 'Maybe Cards');
    });
  }

  Future<List<SwCard>> _loadCards() async {
    List<SwCard> cards = [];

    final filenames = ['data/cards/Light.json', 'data/cards/Dark.json'];

    for (var f in filenames) {
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

    for (var f in filenames) {
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

  SwStack _loadStack(List names, List<SwCard> library, String title) =>
      SwStack.fromCardNames(_currentSide, names, library, title);

  @override
  void initState() {
    _setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStack == null) {
      return new Scaffold(
        key: UniqueKey(),
        appBar: new AppBar(
          title: new Text('Loading...'),
        ),
      );
    } else {
      switch (_currentStep) {
        case 1: // Side
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Pick a Side'),
              backgroundColor: Colors.transparent,
            ),
            drawer: _drawerWidget(context),
            body: new Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    _cardBackWidget(context, 'Dark'),
                    _cardBackWidget(context, 'Light'),
                  ],
                ),
              ),
            ),
          );
          break;

        case 2: // Objective / Archetype
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Pick an Objective (or Starting Location)'),
              backgroundColor: Colors.transparent,
            ),
            drawer: _drawerWidget(context),
            body: new Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    _cardBackWidget(context, 'Dark'),
                    _cardBackWidget(context, 'Light'),
                  ],
                ),
              ),
            ),
          );
          break;

        case 8: // Main Deck
          return new Scaffold(
            key: UniqueKey(),
            appBar: new AppBar(
              title: new Text(
                  "${_currentSide[0]}S | ${_currentDeck.title}\nStack: ${_currentStack.length} | Deck: ${_currentDeck.length} | Maybe: ${_maybeStack.length}"),
              backgroundColor: Colors.transparent,
            ),
            drawer: _drawerWidget(context),
            body: new Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: _tinderCards(context),
              ),
            ),
          );
          break;
      }
    }
  }

  Widget _tinderCards(context) {
    return TinderSwapCard(
      swipeUp: true,
      swipeDown: true,
      orientation: AmassOrientation.TOP,
      totalNum: _currentStack.length,
      stackNum: 8,
      swipeEdge: 4.0,
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.width,
      minWidth: MediaQuery.of(context).size.width * 0.8,
      minHeight: MediaQuery.of(context).size.width * 0.8,
      cardBuilder: _cardBuilder,
      cardController: CardController(),
      swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
        if (align.x.abs() > align.y.abs()) {
          if (align.x < 0) {
            // print("left swipe");
          } else if (align.x > 0) {
            // print("right swipe");
          }
        } else if (align.x.abs() < align.y.abs()) {
          if (align.y < 0) {
            // print("up swipe");
          } else if (align.y > 0) {
            // print("down swipe");
          }
        }
      },
      swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
        setState(() {
          SwCard swipedCard = this._currentStack.removeAt(index);
          switch (orientation) {
            case CardSwipeOrientation.LEFT:
              break;
            case CardSwipeOrientation.RIGHT:
              _currentStack.add(swipedCard);
              break;
            case CardSwipeOrientation.UP:
              _currentDeck.add(swipedCard);
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
    );
  }

  List<Widget> _drawerWidgets(context) {
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
      ListTile(
        leading: Icon(Icons.filter_1),
        title: Text('Side'),
        onTap: () {
          setState(() {
            _currentStack.cards.clear();
          });
          Navigator.pop(context); // close the drawer
        },
      ),
      ListTile(
        leading: Icon(Icons.filter_2),
        title: Text('Objective (or Starting Location)'),
      ),
      ListTile(
        leading: Icon(Icons.subdirectory_arrow_right_rounded),
        title: Text('Deployed by Objective'),
      ),
      ListTile(
        leading: Icon(Icons.filter_3),
        title: Text('Starting Interrupt'),
      ),
      ListTile(
        leading: Icon(Icons.subdirectory_arrow_right_rounded),
        title: Text('Deployed by Starting Interrupt'),
      ),
      ListTile(
        leading: Icon(Icons.filter_5),
        title: Text('Starting Effect'),
      ),
      ListTile(
        leading: Icon(Icons.subdirectory_arrow_right_rounded),
        title: Text('Defensive Shields'),
      ),
      ListTile(
        leading: Icon(Icons.filter_4),
        title: Text('Main Deck'),
      ),
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
                  : Matrix4.rotationZ(_currentSide == 'Light'
                      ? -pi / 2
                      : pi / 2), // according to side
          child: Image.network(_currentStack[index].imageUrl,
              alignment: Alignment.center)),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
    );
  }

  Widget _cardBackWidget(context, side) {
    return Expanded(
      child: new GestureDetector(
        onTap: () {
          setState(() {
            this._currentSide = side;
            this._currentDeck = new SwDeck(side, [], 'New Deck');
            this._currentStep += 1;
          });
        },
        child: Container(
          padding: EdgeInsets.all(5),
          child: Image(
              image: AssetImage(
                  "assets/images/${side == 'Dark' ? 'ds' : 'ls'}-back.jpg")),
        ),
      ),
    );
  }
}
