import 'package:flutter/material.dart';
import 'package:sorcerers_app/online/messages/messages_client.dart';
import 'package:sorcerers_app/online/messages/messages_server.dart';
import 'package:sorcerers_app/online/server_connection.dart';

class OnlineGame with ChangeNotifier {
  late ServerConnection connection;

  LobbyState lobbyState = Idle();

  OnlineGame() {
    connection = ServerConnection(_onMessage);
    connection.initializeConnection();
  }

  void _onMessage(ServerMessage message) {
    var _ = switch (message) {
      StateUpdate() => lobbyState = message.lobbyState,
    };
    notifyListeners();
  }

  void joinLobby(String name) {
    connection.send(JoinLobby(name));
  }

  void leaveLobby(String name) {
    connection.send(LeaveLobby());
  }
}
