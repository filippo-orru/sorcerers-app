import 'package:flutter/material.dart';
import 'package:sorcerers_app/main.dart';
import 'package:sorcerers_core/game/game.dart';
import 'package:sorcerers_core/online/messages/game_messages/game_messages_client.dart';
import 'package:sorcerers_core/online/messages/messages_client.dart';
import 'package:sorcerers_core/online/messages/messages_server.dart';
import 'package:sorcerers_app/online/server_connection.dart';
import 'package:sorcerers_core/utils.dart';

class OnlinePlayProvider with ChangeNotifier {
  late ServerConnection connection;

  PlayerAdapter? adapter;

  OnlinePlayProvider() {
    connection = ServerConnection(_onMessage, _onReconnect);
    connection.initializeConnection();
    connection.addListener(() {
      notifyListeners();
    });
  }

  void _onMessage(ServerMessage message) {
    switch (message) {
      case HelloResponse(playerId: final playerId, reconnectId: final reconnectId):
        adapter = PlayerAdapter(connection, playerId, reconnectId);
        adapter!.sendNewName();
        break;
      default:
        adapter?.onMessage(message);
        break;
    }
    notifyListeners();
  }

  void _onReconnect() {
    connection.send(Hello(adapter?.reconnectId));
  }
}

class PlayerAdapter {
  final ServerConnection connection;

  PlayerId playerId;
  ReconnectId reconnectId;

  PlayerAdapter(this.connection, this.playerId, this.reconnectId);

  LobbyState? lobbyState;

  String? get storedName => globalPrefs.getString('name');
  set storedName(String? value) {
    globalPrefs.setString('name', value!);
  }

  void sendNewName() {
    if (lobbyState != null) {
      return;
    }

    if (storedName != null) {
      connection.send(SetName(storedName!));
    }
  }

  void createLobby(String name) {
    if (lobbyState is! LobbyStateIdle) {
      return;
    }

    connection.send(CreateLobby(name));
  }

  void joinLobby(String name) {
    if (lobbyState is! LobbyStateIdle) {
      return;
    }

    connection.send(JoinLobby(name));
  }

  void leaveLobby() {
    if (lobbyState is! LobbyStateInLobby) {
      return;
    }

    connection.send(LeaveLobby());
  }

  void readyToPlay(bool ready) {
    if (lobbyState is! LobbyStateInLobby) {
      return;
    }

    connection.send(ReadyToPlay(ready));
  }

  void sendGameMessage(GameMessageClient message) {
    if (lobbyState is! LobbyStatePlaying) {
      return;
    }

    connection.send(GameMessage(playerId, message));
  }

  void onMessage(ServerMessage message) {
    switch (message) {
      case StateUpdate(lobbyState: final lobbyState):
        this.lobbyState = lobbyState;
        break;
      default:
        debugPrint("Unhandled message");
    }
  }
}
