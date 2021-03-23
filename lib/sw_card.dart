class SwCard {
  SwCard(this.id, this.side, this.title, this.imageUrl);

  int id;
  String side;
  String title;
  String imageUrl;
  String type;
  String subType;

  SwCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        side = json['side'],
        title = SwCard.normalizeTitle(json['front']['title']),
        type = json['front']['type'],
        subType = json['front']['subType'],
        imageUrl = json['front']['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'side': side,
        'title': title,
        'type': type,
        'subType': subType,
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
