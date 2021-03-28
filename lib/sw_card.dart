class SwCard {
  SwCard(
      this.id,
      this.side,
      this.title,
      this.imageUrl,
      this.gametext,
      this.lore,
      this.icons,
      this.lightSideIcons,
      this.darkSideIcons,
      this.characteristics,
      this.matchingStarship,
      this.matchingWeapon);

  int id;
  String side;
  String title;
  String imageUrl;
  String type;
  String subType;
  String gametext;
  String lore;
  List icons;
  int lightSideIcons;
  int darkSideIcons;
  List characteristics;
  List matchingStarship;
  List matchingWeapon;

  SwCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        side = json['side'],
        title = SwCard.normalizeTitle(json['front']['title']),
        type = json['front']['type'],
        subType = json['front']['subType'],
        gametext = json['front']['gametext'],
        lore = json['front']['lore'],
        icons = json['front']['icons'],
        lightSideIcons = json['front']['lightSideIcons'],
        darkSideIcons = json['front']['darkSideIcons'],
        characteristics = json['front']['characteristics'],
        matchingStarship = json['front']['matching'],
        matchingWeapon = json['front']['matchingWeapon'],
        imageUrl = json['front']['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'side': side,
        'title': title,
        'type': type,
        'subType': subType,
        'gametext': gametext,
        'lore': lore,
        'icons': icons,
        'lightSideIcons': lightSideIcons,
        'darkSideIcons': darkSideIcons,
        'characteristics': characteristics,
        'matching': matchingStarship,
        'matchingWeapon': matchingWeapon,
        'imageUrl': imageUrl,
      };

  static String normalizeTitle(String s) {
    List<String> titles = s.split(' / ');
    String frontTitle = titles[0];
    String backTitle = titles.length > 1 ? titles[1] : '';
    String vSuffix = backTitle.endsWith('(V)') ? ' (V)' : '';

    return (frontTitle + vSuffix).replaceAll('•', '').replaceAll('<>', '');
  }

  static List<SwCard> listFromJson(List list) {
    return list.map((cardMap) => SwCard.fromJson(cardMap)).toList();
  }
}
