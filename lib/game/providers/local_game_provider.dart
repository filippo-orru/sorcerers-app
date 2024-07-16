import 'package:sorcerers_core/game/game.dart';
import 'package:sorcerers_core/online/messages/game_messages/game_messages_client.dart';

import 'game_provider.dart';

class LocalGameProvider extends GameStateProvider {
  late final Game game;

  LocalGameProvider(List<String> playerNames) {
    game = Game(playerNames)..addListener(_onGameUpdate);
    game.startNewRound(incrementRound: false);
    _onGameUpdate();
  }

  void _onMessage(GameMessageClient message) {
    game.onMessage(message);
  }

  void _onGameUpdate() {
    value = game.toState(_onMessage);
    notifyListeners();
  }

  @override
  late GameState value;
}
