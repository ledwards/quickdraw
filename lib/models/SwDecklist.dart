import 'SwCard.dart';
import 'SwStack.dart';
import 'SwDecklistCard.dart';

class SwDecklist {
  String side;
  String title;
  String archetypeName;
  List _decklistCards;

  List cardNames({starting}) => (starting == null
          ? _decklistCards
          : _decklistCards
              .where((decklistCard) => decklistCard.starting == starting))
      .map((decklistCard) => decklistCard.title)
      .toList();

  int get length => _decklistCards.length;

  String get _startingCardName => cardNames()[1];
  SwCard startingCard(SwStack library) => library.findByName(_startingCardName);

// TODO: Preserve the starting/not-starting info
  SwDecklist.fromJson(Map<String, dynamic> json, String title)
      : side = json['userinfo']['deckside'] == 'DS' ? 'Dark' : 'Light',
        title = title,
        archetypeName = json['userinfo']['deckname'],
        _decklistCards = json.keys
            .where((key) => ['userinfo', 'deckinfo'].contains(key) == false)
            .map((key) => json[key]
                .map((name) => SwDecklistCard(name, key == 'STARTING')))
            .expand((e) => e) // flatten
            .toList();

  Map<String, dynamic> toJson() => {
        'side': side,
        'title': title,
        'archetypeName': archetypeName,
        'cardNames': cardNames(),
      };
}
