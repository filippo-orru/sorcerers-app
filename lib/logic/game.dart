import 'package:flutter/material.dart';

sealed class GameCard {
  bool beats(GameCard previous, CardColor? trump, CardColor? lead);

  bool canBePlayed(CardColor? lead);

  String get description;

  Color get backgroundColor;
}

enum CardColor { red, yellow, green, blue }

class NumberCard extends GameCard {
  final int number; // 1-13
  final CardColor color;

  NumberCard(this.number, this.color);

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
  String get description => "Number($number, $color)";

  @override
  Color get backgroundColor => switch (color) {
        CardColor.red => Colors.red.shade200,
        CardColor.yellow => Colors.yellow.shade200,
        CardColor.green => Colors.green.shade200,
        CardColor.blue => Colors.blue.shade200,
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
}

class Deck {
  final List<GameCard> cards;

  Deck() : cards = generateCards();

  static List<GameCard> generateCards() {
    final cards = [
      for (final color in CardColor.values)
        for (var i = 1; i <= 13; i++) NumberCard(i, color),
      for (var i = 0; i < 4; i++) WizardCard(),
      for (var i = 0; i < 4; i++) JesterCard(),
    ];
    cards.shuffle();
    return cards;
  }
}

class Player {
  final String name;
  final List<GameCard> hand = [];

  Player(this.name);

  void playCard(GameCard card) {
    hand.remove(card);
  }

  void drawCard(GameCard card) {
    hand.add(card);
  }

  void clearHand() {
    hand.clear();
  }
}

class CardOnTable {
  final Player player;
  final GameCard card;

  CardOnTable(this.player, this.card);
}

class Game with ChangeNotifier {
  Game(List<String> playerNames)
      : players = playerNames.map((name) => Player(name)).toList(),
        initialPlayerInt = 0 {
    initializeRound();
  }

  final List<Player> players;
  final int initialPlayerInt;

  // Round
  int roundNumber = 0;
  late Deck deck;
  final List<CardOnTable> cardsOnTable = [];
  late int currentPlayerInt;
  Player get currentPlayer => players[currentPlayerInt];

  GameCard? trump;
  CardColor? trumpColor;
  bool mustChooseTrumpColor = false;

  CardColor? get leadColor {
    for (final cardOnTable in cardsOnTable) {
      final card = cardOnTable.card;
      switch (card) {
        case NumberCard():
          return card.color;
        case WizardCard():
          return trumpColor;
        case JesterCard():
          continue; // Is defined by the next card
      }
    }
    return null;
  }

  void initializeRound() {
    deck = Deck();

    if (roundNumber * players.length >= deck.cards.length) {
      throw Exception("Not enough cards in the deck");
    }

    for (final player in players) {
      player.clearHand();
      for (var i = 0; i < (roundNumber + 1); i++) {
        player.drawCard(deck.cards.removeLast());
      }
    }
    final trump = deck.cards.removeLast();
    switch (trump) {
      case NumberCard():
        trumpColor = trump.color;
      case WizardCard():
        mustChooseTrumpColor = true;
      case JesterCard():
        trumpColor = null; // No trump color for this round
    }
    cardsOnTable.clear();
    currentPlayerInt = initialPlayerInt;
    notifyListeners();
  }

  void playCard(Player player, GameCard card) {
    if (player != currentPlayer) {
      throw Exception("Not the player's turn");
    }

    currentPlayer.playCard(card);
    cardsOnTable.add(CardOnTable(player, card));
    currentPlayerInt = (currentPlayerInt + 1) % players.length;
    notifyListeners();
  }

  Player? getRoundWinner() {
    if (players.any((player) => player.hand.isNotEmpty)) {
      return null;
    }

    CardOnTable? winningCard;
    for (final cardOnTable in cardsOnTable) {
      if (winningCard == null) {
        winningCard = cardOnTable;
      } else {
        final card = cardOnTable.card;
        if (card.beats(winningCard.card, trumpColor, leadColor)) {
          winningCard = cardOnTable;
        }
      }
    }
    return winningCard?.player;
  }
}
