import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sorcerers_app/constants.dart';
import 'package:sorcerers_core/online/messages/messages_client.dart';
import 'package:sorcerers_core/online/messages/messages_server.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerConnection with ChangeNotifier {
  final void Function(ServerMessage message) onMessage;
  final void Function() onReconnect;

  ServerConnection(this.onMessage, this.onReconnect);

  WebSocketChannel? channel;

  bool get okay => channel != null && channel!.closeCode == null;
  Timer? _reconnectTimer;

  Timer? _connectionLostLongTimer;
  bool _connectionLostLongTime = false;
  bool get connectionLostLongTime => _connectionLostLongTime;
  set connectionLostLongTime(bool value) {
    _connectionLostLongTime = value;
    notifyListeners();
  }

  int _connectTryCount = 0;

  void initializeConnection() async {
    final channel = WebSocketChannel.connect(Uri.parse("$wsProtocol://$host/ws"));
    try {
      await channel.ready;
    } on Exception catch (e) {
      debugPrint("Error connecting to websocket");
      debugPrint(e.toString());
      debugPrintStack();
      _close();
      return;
    }
    channel.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: true);
    _connectTryCount = 0;

    this.channel = channel;
    onReconnect();
    notifyListeners();
  }

  void send(ClientMessage message) {
    final json = jsonEncode(message.toJson());

    debugPrint(">> $json");
    channel?.sink.add(json);
  }

  void onData(data) {
    if (data is! String) {
      return;
    }

    debugPrint("<< $data");
    final map = jsonDecode(data);
    try {
      final message = ServerMessage.fromJson(map);
      onMessage(message);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void onDone() {
    _close();
  }

  void onError(data) {
    debugPrint("Websocket received error, closing");
    _close();
  }

  void _close() async {
    channel = null;
    if (!connectionLostLongTime) {
      _connectionLostLongTimer ??= Timer(
        const Duration(seconds: 2),
        () {
          connectionLostLongTime = true;
        },
      );
    }
    notifyListeners();

    _reconnectTimer ??= Timer(
      Duration(seconds: min(_connectTryCount, 5)),
      () {
        _connectTryCount += 1;
        initializeConnection();
        _reconnectTimer = null;
      },
    );
  }
}
