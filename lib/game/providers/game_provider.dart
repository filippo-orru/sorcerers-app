import 'package:flutter/foundation.dart';
import 'package:sorcerers_core/game/game.dart';
import 'package:sorcerers_core/online/messages/game_messages/game_messages_client.dart';

abstract class GameStateProvider extends ChangeNotifier {
  GameState get value;

  void sendMessage(GameMessageClient message);
}
