class SwDecklist {
  SwDecklist(this.side, this.title, this.archetype, this.cardNames);

  String side;
  String title;
  String archetype;
  List<String> cardNames;

  SwDecklist.fromJson(Map<String, dynamic> json, String title)
      : side = json['userinfo']['deckside'],
        title = title,
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
        'title': title,
        'archetype': archetype,
        'cardNames': cardNames,
      };
}
