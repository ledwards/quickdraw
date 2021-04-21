class SwCard {
  int id;
  String side;
  String title;
  String backTitle;
  String imageUrl;
  String type;
  String subType;
  String gametext;
  String lore;
  int lightSideIcons;
  int darkSideIcons;
  List<String> icons;
  List<String> characteristics;
  int set;
  String uniqueness;

  SwCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        side = json['side'],
        title = normalizeTitle(json['front']['title']),
        type = json['front']['type'],
        subType = json['front']['subType'],
        gametext = json['front']['gametext'],
        lore = json['front']['lore'],
        lightSideIcons = json['front']['lightSideIcons'],
        darkSideIcons = json['front']['darkSideIcons'],
        icons = castListString(json['front']['icons']),
        characteristics = castListString(json['front']['characteristics']),
        set = int.tryParse(json['set']),
        uniqueness = json['front']['uniqueness'],
        imageUrl = json['front']['imageUrl'];

  // NOTE: This does not put it back into the format with front/back keys
  Map<String, dynamic> toJson() => {'id': id, 'side': side, 'title': title};

  String get displayUniqueness => uniqueness == null
      ? ''
      : uniqueness.replaceAll('*', '•').replaceAll('<>', '⬦');

  // TODO: Make this work with Objective backs
  List<String> _cardsWithDupes = [
    'Sense',
    'Alter',
    'Control',
    'Boba Fett',
    'Tatooine',
    'Coruscant',
    'Jawa',
    'Tusken Raider'
  ];

  // TODO: Use the original title from the card, as some newer v-cards don't have uniqueness string set
  String get displayTitle => "$displayUniqueness$title $displaySet";
  String get displaySet => _cardsWithDupes.contains(title) ? '($set)' : '';

  static String normalizeTitle(String s) {
    List<String> titles = s.split(' / ');
    String frontTitle = titles[0];
    String backTitle = titles.length > 1 ? titles[1] : '';
    String vSuffix = backTitle.endsWith('(V)') ? ' (V)' : '';

    return (frontTitle + vSuffix).replaceAll('•', '').replaceAll('<>', '');
  }

  static List<String> castListString(dynamic data) {
    return data != null
        ? (data as List).map((e) => e.toString()).toList()
        : null;
  }

  static List<SwCard> listFromJson(List list) {
    return list.map((cardMap) => SwCard.fromJson(cardMap)).toList();
  }
}
