import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../models/SwCard.dart';
import '../models/SwDeck.dart';
import '../controllers/Wizard.dart';

class DecklistScroller extends StatefulWidget {
  DecklistScroller({
    Key key,
    @required this.deck,
  }) : super(key: key);

  final SwDeck deck;

  @override
  _DecklistScrollerState createState() => _DecklistScrollerState();
}

class _DecklistScrollerState extends State<DecklistScroller> {
  SwDeck _deck;
  SlidableController slidableController;

  @protected
  void initState() {
    _deck = widget.deck;
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {});
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return _deck.cardsForStep(index).isEmpty
              ? Container()
              : StickyHeader(
                  header: Container(
                    height: 50.0,
                    color: Colors.blueGrey[700],
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Step ${index + 1}: ${Wizard.stepNames[index]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  content: Column(
                    children: _deck
                        .cardsForStep(index)
                        // TODO: Tap to see zoomed in modal
                        .map((SwCard card) => Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  leading: Image.network(
                                    card.imageUrl,
                                    alignment: Alignment.center,
                                  ),
                                  title: Text(card.displayTitle),
                                  subtitle: Text(
                                      "${card.type}"), // TODO: make Qty work
                                ),
                              ),
                              secondaryActions: index == 6
                                  ? <Widget>[
                                      IconSlideAction(
                                        caption: 'add',
                                        color: Colors.green,
                                        icon: Icons.exposure_plus_1,
                                        onTap: () => print('Add'),
                                      ),
                                      IconSlideAction(
                                        caption: 'remove',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () => print('Subtract'),
                                      ),
                                    ]
                                  : null,
                            ))
                        .toList(),
                  ),
                );
        });
  }
}
