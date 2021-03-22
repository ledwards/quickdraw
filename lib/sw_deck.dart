class SwDeck {
  SwDeck(this.side, this.archetype, this.cardNames);

  String side;
  String archetype;
  List cardNames;

  SwDeck.fromJson(Map<String, dynamic> json)
      : side = json['userinfo']['deckside'],
        archetype = json['userinfo']['deckname'],
        cardNames = json.keys
            .where((element) =>
                ['userinfo', 'deckinfo'].contains(element) == false)
            .map((k) => json[k])
            .expand((e) => e) // flatten
            .toList();

  Map<String, dynamic> toJson() => {
        'side': side,
        'archetype': archetype,
        'cardNames': cardNames,
      };

  List normalized() {
    return []; // take a list of SwCards and return a list of objects joinend by name
  }
}
