import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/SwCard.dart';
import '../models/SwStack.dart';
import '../models/SwDeck.dart';

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
    List<Widget> children = _deck.cards
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
                      // leading: CircleAvatar(
                      //   backgroundColor: Colors.indigoAccent,
                      //   child: Text('3'),
                      //   foregroundColor: Colors.white,
                      // ),
                      title: Text(card.displayTitle),
                      subtitle: Text("${card.type}"), // TODO: make Qty work
                    ),
                  ),
                  secondaryActions: <Widget>[
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
                  ],
                )
            // Container(
            //       height: 25,
            //       child: Center(child: Text(card.displayTitle)),
            //     ))
            )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: children,
      ),
    );
  }
}
