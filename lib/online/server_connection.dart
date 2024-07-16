import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sorcerers_app/constants.dart';
import 'package:sorcerers_core/online/messages/messages_client.dart';
import 'package:sorcerers_core/online/messages/messages_server.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerConnection {
  final void Function(ServerMessage message) onMessage;

  ServerConnection(this.onMessage);

  WebSocketChannel? channel;
  bool get okay => channel != null && channel!.closeCode == null;

  void initializeConnection() async {
    final channel = WebSocketChannel.connect(Uri.parse("$wsProtocol$host/ws"));
    try {
      await channel.ready;
    } catch (e) {
      debugPrint("Error connecting to websocket: $e");
      return;
    }
    channel.stream.listen(onData, onError: onError, cancelOnError: true);

    this.channel = channel;
  }

  void send(ClientMessage message) {
    final json = jsonEncode(message.toJson());

    channel!.sink.add(json);
  }

  void onData(data) {
    if (data is! String) {
      return;
    }

    final map = jsonDecode(data);
    try {
      final message = ServerMessage.fromJson(map);
      onMessage(message);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void onError(data) {
    channel = null; // TODO close? retry?
  }
}
