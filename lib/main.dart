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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List allCards = [];
  List allDecklists = [];
  SwStack stack;

  @override
  initState() {
    super.initState();

    _initCards();
    _initDecklists();
  }

  Future _initCards() async {
    final filenames = ['data/cards/Light.json', 'data/cards/Dark.json'];
    filenames.forEach((f) {
      rootBundle.loadString(f).then((String data) {
        var cardsData = json.decode(data);
        setState(() {
          allCards.addAll(SwCard.listFromJson(cardsData['cards']));
          _initStack();
        });
      });
    });
  }

  Future _initDecklists() async {
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final filenames = manifestMap.keys
        .where((key) => key.contains('data/decklists/'))
        .toList();

    filenames.forEach((f) {
      rootBundle.loadString(f).then((String data) {
        setState(() {
          final deckJson = json.decode(data).values.toList()[0];
          allDecklists.add(SwDecklist.fromJson(deckJson));
        });
      });
    });
  }

  _initStack() {
    setState(() {
      stack = SwStack.fromCardNames("Light",
          ["junk", "Han Solo", "Home One", "Admiral Ackbar (V)"], allCards);
    });
  }

  @override
  Widget build(BuildContext context) {
    CardController controller;

    if (stack == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Loading..."),
        ),
      );
    } else {
      return new Scaffold(
        body: new Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: new TinderSwapCard(
              swipeUp: true,
              swipeDown: true,
              orientation: AmassOrientation.TOP,
              totalNum: stack.cards.length,
              stackNum: 8,
              swipeEdge: 4.0,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.width * 0.9,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.width * 0.8,
              cardBuilder: (context, index) => Card(
                child: Image.network(stack.cards[index].imageUrl),
                color: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              cardController: controller = CardController(),
              swipeUpdateCallback:
                  (DragUpdateDetails details, Alignment align) {
                if (align.x < 0) {
                  print("left swipe");
                } else if (align.x > 0) {
                  print(allCards[0].toJson());
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
