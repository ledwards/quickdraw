import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tindercard/flutter_tindercard.dart';

import 'sw_card.dart';

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
  List<SwCard> cardLibrary = [];

  @override
  initState() {
    super.initState();

    rootBundle.loadString('data/cards/Light.json').then((String data) {
      var cardsData = json.decode(data);
      List cardsMapsList = cardsData["cards"];
      var swCards = cardsMapsList.map((cardMap) => SwCard.fromJson(cardMap));

      setState(() {
        cardLibrary.addAll(swCards);
      });

      print(cardLibrary[0].toJson());
      print(cardLibrary[1].toJson());
    });
  }

  @override
  Widget build(BuildContext context) {
    CardController controller;

    if (cardLibrary == null) {
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
              totalNum: cardLibrary.length,
              stackNum: 3,
              swipeEdge: 4.0,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.width * 0.9,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.width * 0.8,
              cardBuilder: (context, index) => Card(
                child: Image.network(cardLibrary[index].imageUrl),
                color: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              cardController: controller = CardController(),
              swipeUpdateCallback:
                  (DragUpdateDetails details, Alignment align) {
                if (align.x < 0) {
                  print("left swipe");
                } else if (align.x > 0) {
                  print("right swipe");
                } else if (align.y < 0) {
                  print("down swipe");
                } else if (align.y > 0) {
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
