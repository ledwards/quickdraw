import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';

import '../models/sw_card.dart';
import '../models/sw_stack.dart';
import '../models/sw_deck.dart';

class SwipeableStack extends StatefulWidget {
  const SwipeableStack({
    Key key,
    @required this.deck,
    @required this.stack,
  }) : super(key: key);

  final SwStack stack;
  final SwDeck deck;

  @override
  _SwipeableStackState createState() => _SwipeableStackState();
}

class _SwipeableStackState extends State<SwipeableStack> {
  SwStack _stack;
  SwDeck _deck;

  @override
  void initState() {
    super.initState();
    _stack = widget.stack;
    _deck = widget.deck;
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
                      break;
                    case CardSwipeOrientation.RIGHT:
                      _stack.add(swipedCard);
                      break;
                    case CardSwipeOrientation.UP:
                      _deck.add(swipedCard);
                      break;
                    case CardSwipeOrientation.DOWN:
                      // TODO: need a maybe stack
                      // _maybeStack.add(swipedCard);
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
            child: Text(
              "Stack: (${_stack.length}), Deck: (${_deck.length})",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
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
