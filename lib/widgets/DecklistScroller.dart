import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:grouped_list/grouped_list.dart';

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
        shrinkWrap: true,
        itemCount: 8,
        itemBuilder: (context, index) {
          return _deck.cardsForStep(index, unique: true).isEmpty
              ? Container()
              : StickyHeader(
                  header: _stepHeader(index),
                  content: Column(children: [
                    _typeList(context, _deck.cardsForStep(index, unique: true),
                        index),
                  ]),
                );
        });
  }

  Widget _typeList(BuildContext context, List<SwCard> cards, int index) {
    return GroupedListView<dynamic, String>(
      shrinkWrap: true,
      elements: cards,
      groupBy: (card) => card.type,
      groupSeparatorBuilder: (String groupByValue) =>
          index == 6 ? _typeHeader(groupByValue) : Container(),
      itemBuilder: (context, dynamic card) => _listCard(card, index),
      groupComparator: (item1, item2) => item1.compareTo(item2),
      itemComparator: (item1, item2) => item1.title.compareTo(item2.title),
      useStickyGroupSeparators: false,
      floatingHeader: true,
      order: GroupedListOrder.ASC,
    );
  }

  Widget _stepHeader(index) {
    return Container(
      height: 45.0,
      color: Colors.black87,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        Wizard.stepNames[index],
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _typeHeader(type) {
    return Container(
      height: 25.0,
      color: Colors.black54,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.center,
      child: Text(
        "${type}s",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _listCard(SwCard card, int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      secondaryActions: index == 6 ? _secondaryActions() : [],
      child: ListTile(
        leading: Image.network(
          card.imageUrl,
          alignment: Alignment.centerLeft,
        ),
        title: Text(card.displayTitle),
        subtitle: Text("x${_deck.qtyFor(card, step: index)}"),
      ),
    );
  }

  List<Widget> _secondaryActions() {
    return <Widget>[
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
    ];
  }
}
