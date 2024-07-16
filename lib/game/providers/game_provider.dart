import 'package:flutter/foundation.dart';
import 'package:sorcerers_core/game/game.dart';

abstract class GameStateProvider extends ChangeNotifier {
  GameState get value;
}
