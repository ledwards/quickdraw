import 'sw_card.dart';
import 'sw_stack.dart';

class SwDecklist {
  String side;
  String title;
  String archetypeName;
  List<String> cardNames;

  int get length => cardNames.length;

  String startingCardName() => cardNames[1];
  SwCard startingCard(SwStack library) {
    return library.findByName(this.startingCardName());
  }

  SwDecklist.fromJson(Map<String, dynamic> json, String title)
      : side = json['userinfo']['deckside'] == 'DS' ? 'Dark' : 'Light',
        title = title,
        archetypeName = json['userinfo']['deckname'],
        cardNames = json.keys
            .where((element) =>
                ['userinfo', 'deckinfo'].contains(element) == false)
            .map((k) => json[k])
            .expand((e) => e) // flatten
            .toList()
            .cast<String>();

  Map<String, dynamic> toJson() => {
        'side': side,
        'title': title,
        'archetypeName': archetypeName,
        'cardNames': cardNames,
      };
}
