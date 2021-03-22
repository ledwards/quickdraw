class SwDecklist {
  SwDecklist(this.side, this.archetype, this.cardNames);

  String side;
  String archetype;
  List<String> cardNames;

  SwDecklist.fromJson(Map<String, dynamic> json)
      : side = json['userinfo']['deckside'],
        archetype = json['userinfo']['deckname'],
        cardNames = json.keys
            .where((element) =>
                ['userinfo', 'deckinfo'].contains(element) == false)
            .map((k) => json[k])
            .expand((e) => e) // flatten
            .toList()
            .cast<String>();

  Map<String, dynamic> toJson() => {
        'side': side,
        'archetype': archetype,
        'cardNames': cardNames,
      };
}
