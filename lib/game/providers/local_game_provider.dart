import 'package:flutter/material.dart';
import 'package:sorcerers_app/game/game.dart';
import 'package:sorcerers_app/messages/game_messages/game_messages_client.dart';

abstract class GameStateProvider extends ChangeNotifier {
  GameState get value;
}

class LocalGameProvider extends GameStateProvider {
  late final Game game;

  LocalGameProvider(List<String> playerNames) {
    game = Game(playerNames)..addListener(_onGameUpdate);
    game.startNewRound(incrementRound: false);
    _onGameUpdate();
  }

  void _onMessage(GameMessageClient message) {
    var _ = switch (message) {
      PlayCard() => game.playCard(game.currentPlayer, message.card),
      StartNewRound() => game.startNewRound(incrementRound: true),
      ShuffleDeck() => game.shuffleAndGiveCards(),
      SetTrumpColor() => game.setTrumpColor(message.color),
      SetBid() => game.setBid(game.currentPlayer, message.bid),
      ReadyForNextTrick() => game.readyForNextTrick(),
      LeaveGame() => game.stop(),
    };
  }

  void _onGameUpdate() {
    value = game.toState(_onMessage);
    notifyListeners();
  }

  @override
  late GameState value;
}
