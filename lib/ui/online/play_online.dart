import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sorcerers_app/online/messages/messages_server.dart';
import 'package:sorcerers_app/online/online_game.dart';
import 'package:sorcerers_app/ui/widget_utils.dart';

class LobbySelectionScreen extends StatefulWidget {
  const LobbySelectionScreen({super.key});

  @override
  State<LobbySelectionScreen> createState() => _LobbySelectionScreenState();
}

class _LobbySelectionScreenState extends State<LobbySelectionScreen> {
  TextEditingController? _newLobbyNameController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaxWidth(
        maxWidth: 400,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<OnlinePlayProvider>(
            builder: (_, provider, __) {
              final lobbyState = provider.lobbyState;
              switch (lobbyState) {
                case null:
                  return const Center(child: CircularProgressIndicator());
                case LobbyStateIdle():
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: const Text(
                          "Select a lobby",
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(.7)),
                        ),
                        child: Column(
                          children: [
                            for (final lobby in lobbyState.lobbies) ...{
                              OutlinedButton(
                                onPressed: () {
                                  provider.joinLobby(lobby.name);
                                },
                                child: Row(
                                  key: ValueKey(lobby.name),
                                  children: [
                                    Text(lobby.name),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            },
                          ],
                        ),
                      ),
                      _newLobbyNameController == null
                          ? OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _newLobbyNameController = TextEditingController());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Create a new lobby"),
                            )
                          : TextField(
                              controller: _newLobbyNameController,
                              decoration: const InputDecoration(
                                labelText: "Lobby name",
                              ),
                              onSubmitted: (value) {
                                provider.createLobby(value);
                                setState(() => _newLobbyNameController = null);
                              },
                            ),
                    ],
                  );
                case InLobby():
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InLobbyScreen(),
                    ),
                  );
                  return const Placeholder();
                case LobbyStatePlaying():
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        throw UnimplementedError();
                        // return const GameScreen(
                        // provider: ,
                        // );
                      },
                    ),
                  );
                  return const Placeholder();
              }
            },
          ),
        ),
      ),
    );
  }
}

class InLobbyScreen extends StatelessWidget {
  const InLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
