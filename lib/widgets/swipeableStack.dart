import 'dart:math' show pi;
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
        Padding(
          padding: const EdgeInsets.only(top: 28.0, bottom: 0.0),
          child: Text(
            _card.displayTitle,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
            padding: EdgeInsets.all(0.0),
            key: UniqueKey(),
            height: MediaQuery.of(context).size.height * 0.5,
            child: TinderSwapCard(
              swipeUp: true,
              swipeDown: true,
              orientation: AmassOrientation.TOP,
              totalNum: _stack.length,
              stackNum: 6,
              swipeEdge: 6.0,
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
        _step == 6
            ? Padding(
                padding: EdgeInsets.only(top: 16.0), child: _stacksCarousel())
            : Container(),
      ],
    );
  }

  Widget _cardBuilder(context, index) {
    return Card(
      margin: EdgeInsets.all(0.0),
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

  // TODO: Most steps, this should show, but show just the current stack
  Widget _stacksCarousel() => CarouselSlider(
        options: CarouselOptions(
          enlargeCenterPage: true,
          height: 150.0,
          viewportFraction: 0.8,
          enableInfiniteScroll: false,
          onPageChanged: null,
        ),
        items: _wizard.sideStacks.values
            .map((SwStack stack) => Builder(
                builder: (BuildContext context) => Container(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 38.0),
                          child: Column(
                            children: [
                              Text(
                                stack.title,
                                style: TextStyle(
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${stack.length} cards",
                                style: TextStyle(
                                  fontSize: 24.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffffff),
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.25),
                              BlendMode.dstATop),
                          image: AssetImage(
                              "assets/images/${_stack.side == 'Dark' ? 'ds' : 'ls'}-back.jpg"),
                        ),
                      ),
                    )))
            .toList(),
      );
}
