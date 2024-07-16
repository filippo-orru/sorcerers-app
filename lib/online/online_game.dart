import 'package:flutter/material.dart';
import 'package:sorcerers_core/online/messages/messages_client.dart';
import 'package:sorcerers_core/online/messages/messages_server.dart';
import 'package:sorcerers_app/online/server_connection.dart';

class OnlinePlayProvider with ChangeNotifier {
  late ServerConnection connection;

  LobbyState? lobbyState;

  OnlinePlayProvider() {
    connection = ServerConnection(_onMessage);
    connection.initializeConnection();
  }

  void _onMessage(ServerMessage message) {
    var _ = switch (message) {
      StateUpdate() => lobbyState = message.lobbyState,
    };
    notifyListeners();
  }

  void createLobby(String name) {
    connection.send(CreateLobby(name));
  }

  void joinLobby(String name) {
    connection.send(JoinLobby(name));
  }

  void leaveLobby(String name) {
    connection.send(LeaveLobby());
  }
}
