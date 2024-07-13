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
  String get description => number.toString();

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

  bool canPlayCard(GameCard card, CardColor? leadColor) {
    if (leadColor == null || card.canBePlayed(leadColor)) {
      // If there is no lead color, any card can be played
      return true;
    } else {
      // If the player has no card of the lead color, they can play any card
      final hasLeadColorCard =
          hand.any((handCard) => handCard is NumberCard && handCard.color == leadColor);
      return !hasLeadColorCard;
    }
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
  int get cardsForRound => roundNumber + 1;
  late Deck deck;
  final Map<Player, RoundScore> roundScores = {};
  RoundState get roundState {
    if (roundScores.length < players.length) {
      return RoundState.predictScore;
    } else if (players.any((player) => player.hand.isNotEmpty)) {
      return RoundState.playing;
    } else {
      return RoundState.finished;
    }
  }

  // Trick
  final List<CardOnTable> cardsOnTable = [];
  int get trickNumber => cardsOnTable.length;
  late int currentPlayerInt;
  Player get currentPlayer => players[currentPlayerInt];

  late GameCard trump;
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

    if (cardsForRound * players.length >= deck.cards.length) {
      throw Exception("Not enough cards in the deck");
    }

    if (roundNumber > 0 && roundState != RoundState.finished) {
      throw Exception("Round not finished");
    }

    for (final player in players) {
      player.clearHand();
      for (var i = 0; i < cardsForRound; i++) {
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
    this.trump = trump;
    cardsOnTable.clear();
    currentPlayerInt = initialPlayerInt;
    notifyListeners();
  }

  void setPredictedScore(Player player, int predictedScore) {
    if (roundState != RoundState.predictScore) {
      throw Exception("Not in the prediction phase");
    }

    roundScores[player] = RoundScore(player, predictedScore);
    notifyListeners();
  }

  void playCard(Player player, GameCard card) {
    if (roundState != RoundState.playing) {
      throw Exception("Not in the playing phase");
    }

    if (player != currentPlayer) {
      throw Exception("Not the player's turn");
    }

    currentPlayer.playCard(card);
    cardsOnTable.add(CardOnTable(player, card));
    currentPlayerInt = (currentPlayerInt + 1) % players.length;

    if (cardsOnTable.length == players.length) {
      // End of the trick
      final winner = getTrickWinner();
      if (winner != null) {
        roundScores[winner]!.wonTrick();
        cardsOnTable.clear(); // TODO don't clear immediately. Wait for players to confirm
        currentPlayerInt = players.indexOf(winner);
      } else {
        throw Exception("Trick finished but no winner?");
      }
    }

    notifyListeners();
  }

  Player? getTrickWinner() {
    if (cardsOnTable.length < players.length) {
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

enum RoundState {
  predictScore,
  playing,
  finished,
}

class RoundScore {
  final Player player;
  final int predictedScore;

  RoundScore(this.player, this.predictedScore);

  int currentScore = 0;

  void wonTrick() {
    currentScore += 1;
  }

  int getPoints() {
    if (currentScore == predictedScore) {
      return 20 + currentScore * 10;
    } else {
      return -10 * (currentScore - predictedScore).abs();
    }
  }
}
