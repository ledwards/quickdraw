import 'package:flutter/material.dart';

class CardBack extends StatelessWidget {
  CardBack(this.side, this.callback);

  final String side;
  final Function callback;

  @override
  Widget build(BuildContext context) {
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
