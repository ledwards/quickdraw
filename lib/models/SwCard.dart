class SwCard {
  int id;
  String side;
  String title;
  String imageUrl;
  String type;
  String subType;
  String gametext;
  String lore;
  int lightSideIcons;
  int darkSideIcons;
  List<String> icons;
  List<String> characteristics;

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
        imageUrl = json['front']['imageUrl'];

  // NOTE: This does not put it back into the format with front/back keys
  Map<String, dynamic> toJson() => {'id': id, 'side': side, 'title': title};

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