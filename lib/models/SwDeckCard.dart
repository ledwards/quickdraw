import 'SwCard.dart';

class SwDeckCard {
  SwDeckCard(this.card, this.stepNumber);

  SwCard card;
  int stepNumber;
  bool active = true;

  bool get starting => stepNumber != 6;
}
