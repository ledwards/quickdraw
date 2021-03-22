import 'sw_card.dart';

class SwStack {
  SwStack(this.side, this.cards);

  String side;
  List<SwCard> cards;

  int get length => cards.length;

  operator [](int index) => cards[index];

  SwStack.fromCardNames(
      String side, List<String> names, List<SwCard> cardLibrary)
      : side = side,
        cards = names
            .map((name) {
              return cardLibrary.firstWhere((c) => c.title == name, orElse: () {
                print("Could not find card when creating Stack");
                print(name);
                return null;
              });
            })
            .where((value) => value != null)
            .toList()
            .cast<SwCard>();
}
