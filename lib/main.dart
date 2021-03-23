import 'dart:convert' show json;
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tindercard/flutter_tindercard.dart';

import 'sw_card.dart';
import 'sw_decklist.dart';
import 'sw_stack.dart';
import 'sw_deck.dart';

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
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SwCard> _allCards = [];
  List<SwDecklist> _allDecklists = [];
  String _currentSide = "Light";
  SwStack _currentStack;
  SwDeck _currentDeck;
  SwStack _maybeStack;
  SwStack _tempStack;

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

  Future _loadDecklists() async {
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

  SwStack _loadStack(List names, List<SwCard> cards, String title) {
    return SwStack.fromCardNames(_currentSide, names, cards, title);
  }

  @override
  void initState() {
    _setup();
    super.initState();
  }

  _setup() async {
    List<SwCard> loadedCards;
    List<SwDecklist> loadedDecklists;
    SwStack stack;

    stack = await Future.wait([_loadCards(), _loadDecklists()]).then((res) {
      loadedCards = res[0];
      loadedDecklists = res[1];
      final decklist = loadedDecklists[1];
      return _loadStack(decklist.cardNames.getRange(0, 3).toList(), loadedCards,
          decklist.title);
    });

    setState(() {
      _allCards = loadedCards;
      _allDecklists = loadedDecklists;
      _currentStack = stack;
      _currentDeck = new SwDeck(_currentSide, [], 'Default Deck');
      _maybeStack = new SwStack(_currentSide, [], 'Maybe Cards');
      _tempStack = new SwStack(_currentSide, [], 'never seen by user');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStack == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Loading..."),
        ),
      );
    } else {
      return Scaffold(
        appBar: new AppBar(
          title: new Text(
              "Stack: ${_currentStack.length} | Temp: ${_tempStack.length} | Deck: ${_currentDeck.length} | Maybe: ${_maybeStack.length}"),
          backgroundColor: Colors.transparent,
        ),
        body: new Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: new TinderSwapCard(
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
              cardBuilder: (context, index) => Card(
                // child: Image.network(_currentStack[index].imageUrl),
                child: Transform(
                    alignment: Alignment.center,
                    transform: _currentStack[index].subType == 'Site'
                        ? Matrix4.rotationZ(-pi / 2)
                        : Matrix4.rotationZ(0),
                    child: Image.network(_currentStack[index].imageUrl,
                        alignment: Alignment.center)),
                color: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              cardController: CardController(),
              swipeUpdateCallback:
                  (DragUpdateDetails details, Alignment align) {
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
              swipeCompleteCallback:
                  (CardSwipeOrientation orientation, int index) {
                setState(() {
                  print("CURR: ${_currentStack.cards.map((e) => e.title)}");
                  print("TEMP: ${_tempStack.cards.map((e) => e.title)}");

                  // There are probably other cases too where you can
                  //end up in the fucked up sitatuion

                  if (orientation != CardSwipeOrientation.RIGHT &&
                      _currentStack.length == 2 &&
                      _tempStack.length == 0) {
                    print("***ITS GONNA FUCK UP IF YOU SWIPE RIGHT, NEXT***");
                    // TODO: disable swipe right?
                  }
                  if (orientation == CardSwipeOrientation.RIGHT &&
                      _currentStack.length == 1 &&
                      _tempStack.length == 0) {
                    print("***ITS FUCKING UP RN***");
                    orientation = CardSwipeOrientation.RECOVER;
                  }

                  switch (orientation) {
                    case CardSwipeOrientation.LEFT:
                      SwCard swipedCard = _currentStack.removeAt(index);
                      break;
                    case CardSwipeOrientation.RIGHT:
                      SwCard swipedCard = _currentStack.removeAt(index);
                      _tempStack.add(swipedCard);
                      break;
                    case CardSwipeOrientation.UP:
                      SwCard swipedCard = _currentStack.removeAt(index);
                      _currentDeck.add(swipedCard);
                      break;
                    case CardSwipeOrientation.DOWN:
                      SwCard swipedCard = _currentStack.removeAt(index);
                      _maybeStack.add(swipedCard);
                      break;
                    case CardSwipeOrientation.RECOVER:
                      break;
                  }
                });

                // print(_currentStack.length);
                // print(_tempStack.length);

                setState(() {
                  if (_currentStack.length == 0) {
                    print('all done');
                    for (int i = 0; i < _tempStack.length; i++) {
                      _currentStack.insert(index + i, _tempStack.cards[i]);
                      print("inserting into ${index + i}");
                    }
                    _tempStack.cards.clear();
                  }
                });
              },
            ),
          ),
        ),
      );
    }
  }
}
