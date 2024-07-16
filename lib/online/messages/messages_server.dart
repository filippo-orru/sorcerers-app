import 'package:sorcerers_app/game/game.dart';
import 'package:sorcerers_app/utils.dart';

sealed class ServerMessage {
  final String id;

  ServerMessage(this.id);

  Map<String, dynamic> toJson();

  static ServerMessage fromJson(Map<String, dynamic> map) {
    final id = map["id"] as String;
    switch (id) {
      case "StateUpdate":
        return StateUpdate.fromJsonImpl(map);
      default:
        throw DeserializationError("Unknown message id: $id");
    }
  }
}

class StateUpdate extends ServerMessage {
  final LobbyState lobbyState;

  StateUpdate(this.lobbyState) : super("StateUpdate");

  static ServerMessage fromJsonImpl(Map<String, dynamic> map) {
    final lobbyState = LobbyState.fromJson(map["lobbyState"] as Map<String, dynamic>);

    return StateUpdate(lobbyState);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "lobbyState": lobbyState.toJson(),
    };
  }
}

sealed class LobbyState {
  static LobbyState fromJson(Map<String, dynamic> map) {
    final id = map["id"] as String;

    switch (id) {
      case "Idle":
        return Idle();
      case "InLobby":
        return InLobby.fromJsonImpl(map);
      case "Playing":
        return Playing.fromJsonImpl(map);
      default:
        throw DeserializationError("Unknown lobby state id: $id");
    }
  }

  Map<String, dynamic> toJson();
}

class Idle extends LobbyState {
  @override
  Map<String, dynamic> toJson() {
    return {
      "id": "Idle",
    };
  }
}

class InLobby extends LobbyState {
  final Map<PlayerId, PlayerInLobby> players;

  InLobby(this.players);

  static LobbyState fromJsonImpl(Map<String, dynamic> map) {
    final players = map["players"] as Map<String, dynamic>;

    final playerMap = <String, PlayerInLobby>{};
    players.forEach((key, value) {
      if (value is! Map<String, dynamic>) {
        return;
      }

      final name = value["name"];
      final ready = value["ready"];
      if (name == null || ready == null) {
        return;
      }

      playerMap[key] = PlayerInLobby(name, ready);
    });

    return InLobby(playerMap);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": "InLobby",
      "players": players.map((key, playerInLobby) => MapEntry(key, playerInLobby.toJson())),
    };
  }
}

class PlayerInLobby {
  final String name;
  final bool ready;

  PlayerInLobby(this.name, this.ready);
  // final bool me;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "ready": ready,
    };
  }
}

class Playing extends LobbyState {
  final GameState gameState;

  Playing(this.gameState);

  static LobbyState fromJsonImpl(Map<String, dynamic> map) {
    final gameState = map["gameState"] as Map<String, dynamic>;

    return Playing(GameState.fromJson(gameState));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": "Playing",
      "gameState": gameState.toJson(),
    };
  }
}
