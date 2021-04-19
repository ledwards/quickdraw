import 'package:flutter/material.dart';

class CardBackPicker extends StatelessWidget {
  CardBackPicker(this.callback);

  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: ['Dark', 'Light'].map((side) => _cardBack(side)).toList(),
        ),
      ),
    );
  }

  Widget _cardBack(side) {
    return Expanded(
      child: new GestureDetector(
        onTap: () => callback(side),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Image(
              image: AssetImage(
                  "assets/images/${side == 'Dark' ? 'ds' : 'ls'}-back.jpg")),
        ),
      ),
    );
  }
}
