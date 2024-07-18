import 'package:sorcerers_app/online/online_game.dart';
import 'package:sorcerers_core/game/game.dart';
import 'package:sorcerers_app/game/providers/game_provider.dart';

class OnlineGameProvider extends GameStateProvider {
  final OnlinePlayProvider provider;

  @override
  GameState value = GameState.loading();

  OnlineGameProvider(this.provider);
}
