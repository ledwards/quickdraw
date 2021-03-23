class SwCard {
  SwCard(this.id, this.side, this.title, this.imageUrl);

  int id;
  String side;
  String title;
  String imageUrl;

  SwCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        side = json['side'],
        title = SwCard.scrub(json['front']['title']).split(' / ')[0],
        imageUrl = json['front']['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'side': side,
        'title': title,
        'imageUrl': imageUrl,
      };

  static String scrub(String s) {
    return s.replaceAll('•', '').replaceAll('<>', '');
  }

  static List<SwCard> listFromJson(List list) {
    return list.map((cardMap) => SwCard.fromJson(cardMap)).toList();
  }
}
