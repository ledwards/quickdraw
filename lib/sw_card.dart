class SwCard {
  SwCard(this.id, this.side, this.title, this.imageUrl);

  int id;
  String side;
  String title;
  String imageUrl;

  SwCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        side = json['side'],
        title = json['front']['title'],
        imageUrl = json['front']['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'side': side,
        'title': title,
        'imageUrl': imageUrl,
      };
}
