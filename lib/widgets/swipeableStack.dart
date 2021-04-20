import 'dart:math' show pi;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../models/SwCard.dart';
import '../models/SwStack.dart';
import '../models/SwDeck.dart';
import '../models/SwArchetype.dart';

import '../controllers/Wizard.dart';

import '../rules/Metagame.dart';

class SwipeableStack extends StatefulWidget {
  const SwipeableStack({
    Key key,
    @required this.step,
    @required this.wizard,
    @required this.deck,
    @required this.meta,
  }) : super(key: key);

  final int step;
  final Wizard wizard;
  final SwDeck deck;
  final Metagame meta;

  @override
  _SwipeableStackState createState() => _SwipeableStackState();
}

class _SwipeableStackState extends State<SwipeableStack> {
  int _step;
  Wizard _wizard;
  SwDeck _deck;
  SwCard _card;
  SwArchetype _archetype;
  Metagame _meta;
  SwStack get _stack => _wizard.currentStack;
  SwStack get _maybe => _wizard.sideStacks['maybe'];
  SwStack get _trash => _wizard.sideStacks['trash'];
  var pct = NumberFormat("###.#", "en_US");

  @override
  void initState() {
    super.initState();
    _step = widget.step;
    _wizard = widget.wizard;
    _deck = widget.deck;
    _meta = widget.meta;
  }

  @override
  Widget build(BuildContext context) {
    _card = _stack[0];
    _archetype = _deck.archetype;

    return Column(
      key: UniqueKey(),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "\n\nStack (${_stack.length}) Deck (${_deck.length}) Maybe (${_maybe.length}) Trash (${_trash.length})",
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        Container(
            key: UniqueKey(),
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
                  SwCard swipedCard = _stack.removeAt(index);
                  switch (orientation) {
                    case CardSwipeOrientation.LEFT:
                      _trash.add(swipedCard);
                      break;
                    case CardSwipeOrientation.RIGHT:
                      _deck.add(swipedCard, _step);
                      break;
                    case CardSwipeOrientation.UP:
                      _stack.add(swipedCard);
                      break;
                    case CardSwipeOrientation.DOWN:
                      _maybe.add(swipedCard);
                      break;
                    case CardSwipeOrientation.RECOVER:
                      _stack.insert(index, swipedCard);
                      break;
                  }
                });
              },
            )),
        // CarouselSlider(
        //   options: CarouselOptions(
        //     enlargeCenterPage: true,
        //     height: 120.0,
        //     viewportFraction: 0.375,
        //     enableInfiniteScroll: false,
        //     onPageChanged: null,
        //   ),
        //   items: _wizard.sideStacks.values.map((SwStack stack) {
        //     return Builder(
        //       builder: (BuildContext context) {
        //         return Container(
        //             width: MediaQuery.of(context).size.width,
        //             margin: EdgeInsets.symmetric(horizontal: 5.0),
        //             decoration: BoxDecoration(color: Colors.grey.shade900),
        //             child: Padding(
        //               padding: const EdgeInsets.all(18.0),
        //               child: Text(
        //                 "${stack.title} (${stack.length})",
        //                 textAlign: TextAlign.center,
        //                 style: TextStyle(fontSize: 18.0, color: Colors.white70),
        //               ),
        //             ));
        //       },
        //     );
        //   }).toList(),
        // ),
        Text(
          _card.title,
          style: Theme.of(context).textTheme.headline5,
          textAlign: TextAlign.center,
        ),
        Text(
          _deck.archetype == null
              ? "\nPopularity: ${_meta.inclusion(_card, starting: _wizard.starting)}/${_meta.decklists.length} (${pct.format(100 * _meta.rateOfInclusion(_card, starting: _wizard.starting))}%)"
              : "\n${_wizard.starting ? 'Started' : 'Included'} in ${pct.format(100 * _archetype.rateOfInclusion(_card, starting: _wizard.starting))}% of ${_archetype.title} decks, ${pct.format(100 * _meta.rateOfInclusion(_card, starting: _wizard.starting))}% overall, \nan average of ${pct.format(_archetype.averageFrequencyPerInclusion(_card, starting: _wizard.starting))}x for this archetype, or ${pct.format(_meta.averageFrequencyPerInclusion(_card, starting: _wizard.starting))}x overall",
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
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
