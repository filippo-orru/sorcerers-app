import 'package:sorcerers_app/online/online_game.dart';
import 'package:sorcerers_core/game/game.dart';
import 'package:sorcerers_app/game/providers/game_provider.dart';
import 'package:sorcerers_core/online/messages/game_messages_client.dart';

class OnlineGameProvider extends GameStateProvider {
  final OnlinePlayProvider provider;

  GameState _value = GameState.loading();

  @override
  GameState get value => _value;

  set value(GameState value) {
    _value = value;
    notifyListeners();
  }

  OnlineGameProvider(this.provider);

  @override
  void sendMessage(GameMessageClient message) {
    provider.adapter?.sendGameMessage(message);
  }
}
