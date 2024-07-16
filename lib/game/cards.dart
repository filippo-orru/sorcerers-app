import 'package:flutter/material.dart';

sealed class GameCard {
  bool beats(GameCard previous, CardColor? trump, CardColor? lead);

  bool canBePlayed(CardColor? lead);

  String get description;

  Color get backgroundColor;

  Map<String, dynamic> toJson();
}

enum CardColor {
  red,
  yellow,
  green,
  blue;

  Color get color => switch (this) {
        CardColor.red => Colors.red.shade200,
        CardColor.yellow => Colors.yellow.shade200,
        CardColor.green => Colors.green.shade200,
        CardColor.blue => Colors.blue.shade200,
      };
}

class NumberCard extends GameCard {
  final int number; // 1-13
  final CardColor color;

  NumberCard(this.number, this.color);

  static int highest = 13;

  @override
  bool beats(GameCard previous, CardColor? trump, CardColor? lead) {
    switch (previous) {
      case NumberCard():
        if (color == previous.color) {
          return number > previous.number;
        } else if (color == trump) {
          return true;
        } else if (color == lead) {
          return true;
        } else {
          return false;
        }
      case WizardCard():
        return false;
      case JesterCard():
        return true;
    }
  }

  @override
  bool canBePlayed(CardColor? lead) {
    return lead == null || lead == color;
  }

  @override
  String get description => number.toString();

  @override
  Color get backgroundColor => color.color;

  @override
  Map<String, dynamic> toJson() => {
        "id": "NumberCard",
        "number": number,
        "color": color.toString(),
      };
}

class WizardCard extends GameCard {
  @override
  bool beats(GameCard previous, CardColor? trump, CardColor? lead) {
    switch (previous) {
      case NumberCard():
        return true;
      case WizardCard():
        return false;
      case JesterCard():
        return true;
    }
  }

  @override
  bool canBePlayed(CardColor? lead) => true;

  @override
  String get description => "Wizard";

  @override
  Color get backgroundColor => Colors.grey.shade200;

  @override
  Map<String, dynamic> toJson() => {
        "id": "WizardCard",
      };
}

class JesterCard extends GameCard {
  @override
  bool beats(GameCard previous, CardColor? trump, CardColor? lead) {
    return false;
  }

  @override
  bool canBePlayed(CardColor? lead) => true;

  @override
  String get description => "Jester";

  @override
  Color get backgroundColor => Colors.purple.shade200;

  @override
  Map<String, dynamic> toJson() => {
        "id": "JesterCard",
      };
}
