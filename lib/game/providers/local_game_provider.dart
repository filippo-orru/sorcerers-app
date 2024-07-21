import 'package:sorcerers_core/game/game.dart';
import 'package:sorcerers_core/online/messages/game_messages/game_messages_client.dart';

import 'game_provider.dart';

class LocalGameProvider extends GameStateProvider {
  late final Game game;

  LocalGameProvider(List<String> playerNames) {
    game = Game(playerNames.indexed.map((it) => Player(it.$1.toString(), it.$2)).toList())
      ..addListener(_onGameUpdate);
    game.startNewRound(incrementRound: false);
    _onGameUpdate();
  }

  void _onGameUpdate() {
    value = game.toState(game.currentPlayer.id);
    notifyListeners();
  }

  @override
  late GameState value;

  @override
  void sendMessage(GameMessageClient message) {
    game.onMessage(
      fromPlayerId:
          game.currentPlayer.id, // When playing on one device, we are always the "current player"
      message: message,
    );
  }
}
