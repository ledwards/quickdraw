import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tindercard/flutter_tindercard.dart';

import 'sw_card.dart';
import 'sw_decklist.dart';
import 'sw_stack.dart';

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
  List<SwCard> allCards = [];
  List<SwDecklist> allDecklists = [];
  SwStack stack;
  String side = "Dark";

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
    return SwStack.fromCardNames(side, names, cards, title);
  }

  @override
  void initState() {
    _setup();
    super.initState();
  }

  _setup() async {
    List<SwCard> _cards;
    List<SwDecklist> _decklists;
    SwStack _stack;

    _stack = await Future.wait([_loadCards(), _loadDecklists()]).then((res) {
      _cards = res[0];
      _decklists = res[1];
      final decklist = _decklists[1];
      return _loadStack(decklist.cardNames, _cards, decklist.title);
    });

    setState(() {
      allCards = _cards;
      allDecklists = _decklists;
      stack = _stack;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (stack == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Loading..."),
        ),
      );
    } else {
      return Scaffold(
        appBar: new AppBar(
          title: new Text(stack.title),
          backgroundColor: Colors.transparent,
        ),
        body: new Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: new TinderSwapCard(
              swipeUp: true,
              swipeDown: true,
              orientation: AmassOrientation.TOP,
              totalNum: stack.length,
              stackNum: 8,
              swipeEdge: 4.0,
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.width,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.width * 0.8,
              cardBuilder: (context, index) => Card(
                child: Image.network(stack[index].imageUrl),
                color: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              cardController: CardController(),
              swipeUpdateCallback:
                  (DragUpdateDetails details, Alignment align) {
                if (align.x < 0) {
                  print("left swipe");
                } else if (align.x > 0) {
                  print("right swipe");
                } else if (align.y > 0) {
                  print("down swipe");
                } else if (align.y < 0) {
                  print("up swipe");
                }
              },
              swipeCompleteCallback:
                  (CardSwipeOrientation orientation, int index) {
                print("Swipe Complete");
              },
            ),
          ),
        ),
      );
    }
  }
}
