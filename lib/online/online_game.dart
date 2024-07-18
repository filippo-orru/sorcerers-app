import 'package:flutter/material.dart';
import 'package:sorcerers_app/main.dart';
import 'package:sorcerers_core/online/messages/messages_client.dart';
import 'package:sorcerers_core/online/messages/messages_server.dart';
import 'package:sorcerers_app/online/server_connection.dart';

class OnlinePlayProvider with ChangeNotifier {
  late ServerConnection connection;

  LobbyState? lobbyState;

  String? get storedName => globalPrefs.getString('name');
  set storedName(String? value) {
    globalPrefs.setString('name', value!);
    notifyListeners();
  }

  OnlinePlayProvider() {
    connection = ServerConnection(_onMessage);
    connection.initializeConnection();
    connection.addListener(() {
      notifyListeners();
    });

    sendNewName();
  }

  void _onMessage(ServerMessage message) {
    var _ = switch (message) {
      StateUpdate() => lobbyState = message.lobbyState,
    };
    notifyListeners();
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
}
