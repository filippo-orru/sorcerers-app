import 'package:flutter/foundation.dart';
import 'package:sorcerers_app/game/game.dart';

abstract class GameStateProvider extends ChangeNotifier {
  GameState get value;
}
