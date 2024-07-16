import 'package:sorcerers_app/game/game.dart';
import 'package:sorcerers_app/online/messages/game_messages/game_messages_client.dart';

import 'game_provider.dart';

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
