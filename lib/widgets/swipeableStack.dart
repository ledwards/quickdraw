import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';

import '../models/SwCard.dart';
import '../models/SwStack.dart';
import '../models/SwDeck.dart';

class SwipeableStack extends StatefulWidget {
  const SwipeableStack({
    Key key,
    @required this.deck,
    @required this.stack,
    @required this.maybe,
    @required this.trash,
    @required this.step,
  }) : super(key: key);

  final SwDeck deck;
  final SwStack stack;
  final SwStack maybe;
  final SwStack trash;
  final int step;

  @override
  _SwipeableStackState createState() => _SwipeableStackState();
}

class _SwipeableStackState extends State<SwipeableStack> {
  SwDeck _deck;
  SwStack _stack;
  SwStack _maybe;
  SwStack _trash;
  int _step;

  @override
  void initState() {
    super.initState();
    _deck = widget.deck;
    _stack = widget.stack;
    _maybe = widget.maybe;
    _trash = widget.trash;
    _step = widget.step;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: TinderSwapCard(
              swipeUp: true,
              swipeDown: true,
              orientation: AmassOrientation.TOP,
              totalNum: _stack.length,
              stackNum: 6,
              swipeEdge: 4.0,
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.width,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.width * 0.8,
              cardBuilder: _cardBuilder,
              cardController: CardController(),
              swipeCompleteCallback:
                  (CardSwipeOrientation orientation, int index) {
                setState(() {
                  SwCard swipedCard = this._stack.removeAt(index);
                  switch (orientation) {
                    case CardSwipeOrientation.LEFT:
                      _trash.add(swipedCard);
                      break;
                    case CardSwipeOrientation.RIGHT:
                      _deck.add(swipedCard, _step);
                      break;
                    case CardSwipeOrientation.UP:
                      _maybe.add(swipedCard);
                      break;
                    case CardSwipeOrientation.DOWN:
                      _stack.add(swipedCard);
                      break;
                    case CardSwipeOrientation.RECOVER:
                      _stack.insert(index, swipedCard);
                      break;
                  }
                });
              },
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "${_deck.cardsForStep(_step).map((SwCard card) => card.title).join(', ')}\n",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Stack: (${_stack.length}) Deck: (${_deck.length})\nMaybe: (${_maybe.length}) Trash: (${_trash.length})",
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _cardBuilder(context, index) {
    return Card(
      child: Transform(
          alignment: Alignment.center,
          transform: _stack[0].subType != 'Site'
              ? (_stack[index].subType == 'Site') // all vertical
                  ? Matrix4.rotationZ(-pi / 2)
                  : Matrix4.rotationZ(0)
              : (_stack[index].subType == 'Site') // all horizontal
                  ? Matrix4.rotationZ(0)
                  : Matrix4.rotationZ(_stack.side == 'Light'
                      ? -pi / 2
                      : pi / 2), // according to side
          child: Image.network(
            _stack[index].imageUrl,
            alignment: Alignment.center,
          )),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
    );
  }
}
