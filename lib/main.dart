import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

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
import 'widgets/DecklistScroller.dart';

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
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
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

// TODO: I think most of this belongs in the RootPage class?
class _RootPageState extends State<RootPage> {
  Wizard get wizard => Provider.of<Wizard>(context, listen: false);
  SwDeck get currentDeck => Provider.of<SwDeck>(context, listen: false);
  Metagame meta = Metagame(null);
  SwStack get currentStack => wizard.currentStack;

  Function _setupForStep(int i) => wizard.steps[i].setup();
  void nextStep() => wizard.nextStep();
  void clearCallbacks() => wizard.clearCallbacks(currentDeck);
  void addStepListener() => wizard.addCurrentStepListener(currentDeck);

  int currentIndex =
      0; // TODO: default to 1 if no decklists saved or deck not empty

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
      currentStack.refresh(SwStack.fromStack(results[1], 'Choose A Side'));
    });

    _stepOne().setup();
    _attachListeners();
  }

  _attachListeners() {
    wizard.addListener(() {
      clearCallbacks();
      // TODO: clear cards from this step and dependent steps
      setState(() => _setupForStep(wizard.stepNumber));
    });

    currentDeck.addListener(() {
      int length = currentDeck.length;
      List<SwCard> justAddedCards =
          currentDeck.sublist(wizard.deckCursor, length);
      wizard.deckCursor = length;

      setState(() {
        var pct = NumberFormat("###.#", "en_US");
        for (SwCard card in justAddedCards) {
          _showCardAddedNotif(card);
          print("Added: ${card.title}");
          print(
            currentDeck.archetype == null
                ? "\nPopularity: ${meta.inclusion(card, starting: wizard.starting)}/${meta.decklists.length} (${pct.format(100 * meta.rateOfInclusion(card, starting: wizard.starting))}%)"
                : "\n${wizard.starting ? 'Started' : 'Included'} in ${pct.format(100 * currentDeck.archetype.rateOfInclusion(card, starting: wizard.starting))}% of ${currentDeck.archetype.title} decks, ${pct.format(100 * meta.rateOfInclusion(card, starting: wizard.starting))}% overall, \nan average of ${pct.format(currentDeck.archetype.averageFrequencyPerInclusion(card, starting: wizard.starting))}x for this archetype, or ${pct.format(meta.averageFrequencyPerInclusion(card, starting: wizard.starting))}x overall",
          );
        }
      });
    });
  }

  _showCardAddedNotif(card) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        duration: Duration(milliseconds: 600),
        content: new Text(
          "Added ${card.displayTitle}",
          style: TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        )));
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    String title;

    switch (currentIndex) {
      case 0:
        title = 'Pick A Side';
        body = CardBackPicker(_stepOne().callback);
        break;

      case 1:
        title = currentStack.title;
        body = SwipeableStack(
          step: wizard.stepNumber,
          wizard: wizard,
          deck: currentDeck,
          meta: meta,
        );
        break;

      case 2:
        title = "Decklist (${currentDeck.length})";
        body = DecklistScroller(deck: currentDeck);
        break;
    }
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(title: Text(title)),
      drawer: wizard.stepNumber == 1 ? null : QuickDrawer(),
      drawerEnableOpenDragGesture: false,
      body: body,
      bottomNavigationBar: TitledBottomNavigationBar(
          activeColor: Colors.black,
          inactiveColor: Colors.grey,
          inactiveStripColor: Colors.white,
          indicatorColor: Colors.white,
          currentIndex: currentIndex,
          reverse: true,
          // Use this to update the Bar giving a position
          onTap: (index) {
            // TODO: Scroll to the bottom of the page is it's tab 3
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            TitledNavigationBarItem(
                title: Text('Decks',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
                icon: Icon(Icons.storage_outlined)),
            TitledNavigationBarItem(
                title: Text(
                  'Builder',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
                icon: Icon(Icons.construction_outlined)),
            TitledNavigationBarItem(
                title: Text(
                  'Decklist',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
                icon: Icon(Icons.article_outlined)),
          ]),
    );
  }

  WizardStep _stepOne() {
    return WizardStep(wizard, () {
      print('Step: 1');
    }, (side) {
      print("Picked $side Side");
      setState(() {
        currentIndex = 1;
        currentDeck.side = side;
        wizard.setup(side, meta, currentDeck);
      });
    });
  }
}
