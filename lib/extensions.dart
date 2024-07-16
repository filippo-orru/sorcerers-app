import 'package:flutter/material.dart';
import 'package:sorcerers_core/game/cards.dart';

extension IntExtension on int {
  String withSign() => sign >= 0 ? "+$this" : "$this";
}

extension CardExtension on GameCard {
  Color get backgroundColor => switch (this) {
        NumberCard(color: CardColor cardColor) => cardColor.color,
        WizardCard() => Colors.grey.shade200,
        JesterCard() => Colors.purple.shade200,
      };
}

extension CardColorExtension on CardColor {
  Color get color => switch (this) {
        CardColor.red => Colors.red.shade200,
        CardColor.yellow => Colors.yellow.shade200,
        CardColor.green => Colors.green.shade200,
        CardColor.blue => Colors.blue.shade200,
      };
}
