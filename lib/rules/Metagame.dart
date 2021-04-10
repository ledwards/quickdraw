import '../models/SwArchetype.dart';
import '../models/SwDecklist.dart';
import '../models/SwStack.dart';

class Metagame {
  Metagame(String side)
      : side = side,
        allCards = null,
        allArchetypes = [],
        allDecklists = [];

  String side;
  SwStack allCards;
  List<SwArchetype> allArchetypes;
  List<SwDecklist> allDecklists;

  SwStack get library => side == null ? allCards : allCards.bySide(side);
  List<SwArchetype> get archetypes => // by side?
      allArchetypes.where((SwArchetype a) => a.side == side).toList();
  List<SwDecklist> get decklists => // by side?
      allDecklists.where((SwDecklist d) => d.side == side).toList();
}
