import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sorcerers_app/game/providers/game_provider.dart';
import 'package:sorcerers_app/game/providers/online_game_provider.dart';
import 'package:sorcerers_app/ui/game_screen.dart';
import 'package:sorcerers_core/game/game.dart';

import 'package:sorcerers_core/online/messages/messages_server.dart';
import 'package:sorcerers_app/online/online_game.dart';
import 'package:sorcerers_app/ui/widget_utils.dart';

class OnlinePlayWrapper extends StatefulWidget {
  const OnlinePlayWrapper({super.key});

  @override
  State<OnlinePlayWrapper> createState() => _OnlinePlayWrapperState();
}

class _OnlinePlayWrapperState extends State<OnlinePlayWrapper> {
  final curveTween = CurveTween(curve: Curves.easeOutQuad);

  @override
  Widget build(BuildContext context) {
    return RequireConnection(
      child: Consumer<OnlinePlayProvider>(
        builder: (_, provider, __) {
          final adapter = provider.adapter!;
          final lobbyState = adapter.lobbyState;

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                key: ValueKey<Key?>(child.key),
                opacity: animation.drive(curveTween),
                child: child,
              );
            },
            layoutBuilder: layoutWithBackground(context),
            child: switch (lobbyState) {
              null => NameSelectionScreen(key: ValueKey("name")),
              LobbyStateIdle() => LobbySelectionScreen(
                  key: ValueKey("idle"),
                  adapter: adapter,
                  lobbyState: lobbyState,
                ),
              LobbyStateInLobby() => InLobbyScreen(
                  key: ValueKey("inLobby"),
                  lobbyState: lobbyState,
                ),
              LobbyStatePlaying() => PlayOnlineGameScreen(
                  key: ValueKey("playing"),
                )
            },
          );
        },
      ),
    );
  }
}

class NameSelectionScreen extends StatefulWidget {
  const NameSelectionScreen({super.key});

  @override
  State<NameSelectionScreen> createState() => _NameSelectionScreenState();
}

class _NameSelectionScreenState extends State<NameSelectionScreen> {
  final _nameEditingController = TextEditingController();
  bool _nameMustBeLonger = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlinePlayProvider>(
      builder: (_, provider, __) {
        final adapter = provider.adapter!;
        void setName() {
          final value = _nameEditingController.text;
          if (value.length <= 3) {
            setState(() {
              _nameMustBeLonger = true;
            });
            return;
          }
          adapter.storedName = value;
          adapter.sendNewName();
        }

        if (adapter.storedName == null) {
          return MenuWithBack(
            title: "What's your name?",
            children: [
              TextField(
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]*")),
                ],
                maxLength: 16,
                decoration: InputDecoration(
                  labelText: "Name",
                  error: _nameMustBeLonger ? Text("Name must be longer") : null,
                ),
                controller: _nameEditingController,
                onChanged: (_) {
                  if (_nameMustBeLonger) {
                    setState(() {
                      _nameMustBeLonger = false;
                    });
                  }
                },
                onSubmitted: (_) {
                  setName();
                },
              ),
              const SizedBox(height: 8),
              const Text(
                "Your name will be visible to other players. You can use letters and numbers.",
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setName();
                },
                child: Text("Submit"),
              ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class LobbySelectionScreen extends StatefulWidget {
  final PlayerAdapter adapter;
  final LobbyStateIdle lobbyState;

  const LobbySelectionScreen({
    super.key,
    required this.adapter,
    required this.lobbyState,
  });

  @override
  State<LobbySelectionScreen> createState() => _LobbySelectionScreenState();
}

class _LobbySelectionScreenState extends State<LobbySelectionScreen> {
  bool _creatingLobby = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      layoutBuilder: layoutWithBackground(context),
      child: _creatingLobby ? _createLobby() : _lobbyList(),
    );
  }

  MenuWithBack _lobbyList() {
    return MenuWithBack(
      title: "Select a lobby",
      onBack: (ctx) => widget.adapter.leaveLobby(),
      children: [
        if (widget.lobbyState.lobbies.isNotEmpty) ...[
          for (final lobby in widget.lobbyState.lobbies) ...[
            OutlinedButton.icon(
              onPressed: () {
                widget.adapter.joinLobby(lobby.name);
              },
              icon: Icon(Icons.arrow_right_sharp),
              label: Row(
                key: ValueKey(lobby.name),
                children: [
                  Text(lobby.name),
                  const Spacer(),
                  Icon(Icons.person_sharp, size: 14),
                  const SizedBox(width: 4),
                  Text("${lobby.playerCount}")
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ] else ...[
          Text("No lobbies available, create one instead!"),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            setState(() => _creatingLobby = true);
          },
          icon: const Icon(Icons.add),
          label: const Text("Create a new lobby"),
        ),
      ],
    );
  }

  LobbyCreationScreen _createLobby() {
    return LobbyCreationScreen(
      createLobby: (name) {
        widget.adapter.createLobby(name);
        setState(() => _creatingLobby = false);
      },
      onBack: () => setState(() => _creatingLobby = false),
    );
  }
}

class LobbyCreationScreen extends StatefulWidget {
  final void Function(String) createLobby;
  final void Function() onBack;

  const LobbyCreationScreen({super.key, required this.createLobby, required this.onBack});

  @override
  State<LobbyCreationScreen> createState() => _LobbyCreationScreenState();
}

class _LobbyCreationScreenState extends State<LobbyCreationScreen> {
  bool _triedCreatingShortName = false;

  final TextEditingController _newLobbyNameController = TextEditingController();
  final FocusNode _newLobbyNameFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MenuWithBack(
      title: "Create Lobby",
      onBack: (_) => widget.onBack(),
      children: [
        TextField(
          autofocus: true,
          controller: _newLobbyNameController,
          focusNode: _newLobbyNameFocus,
          maxLength: 24,
          decoration: const InputDecoration(
            labelText: "Lobby name",
          ),
          buildCounter: (_, {int? currentLength, int? maxLength, bool? isFocused}) {
            final l = currentLength ?? 0;
            if (l <= 3 && _triedCreatingShortName) {
              return const Text("Enter a longer name");
            } else if (l >= maxLength! - 5) {
              return Text("$currentLength/$maxLength");
            } else {
              return null;
            }
          },
          onSubmitted: (value) {
            widget.createLobby(value);
          },
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            if (_newLobbyNameController.text.length <= 3) {
              setState(() => _triedCreatingShortName = true);
              _newLobbyNameFocus.requestFocus();
              return;
            }
            setState(() => _triedCreatingShortName = false);

            widget.createLobby(_newLobbyNameController.text);
          },
          child: const Text("Create lobby"),
        ),
      ],
    );
  }
}

class RequireConnection extends StatefulWidget {
  final Widget child;

  const RequireConnection({super.key, required this.child});

  @override
  State<RequireConnection> createState() => _RequireConnectionState();
}

class _RequireConnectionState extends State<RequireConnection> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OnlinePlayProvider>(
      builder: (_, provider, __) {
        if (provider.connection.okay && provider.adapter != null) {
          return widget.child;
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  AnimatedOpacity(
                    opacity: provider.connection.connectionLostLongTime ? 1 : 0,
                    duration: Duration(seconds: 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 16),
                        Text("Waiting for connection..."),
                        SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            provider.adapter?.leaveLobby();
                            Navigator.of(context).popUntil((r) => r.isFirst);
                          },
                          child: Text("Leave"),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class InLobbyScreen extends StatelessWidget {
  final LobbyStateInLobby lobbyState;

  const InLobbyScreen({super.key, required this.lobbyState});

  @override
  Widget build(BuildContext context) {
    final adapter = context.watch<OnlinePlayProvider>().adapter!;

    final PlayerInLobby? me = lobbyState.players
        .map<PlayerInLobby?>((i) => i)
        .firstWhere((playerInLobby) => playerInLobby?.id == adapter.playerId, orElse: () => null);
    if (me == null) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      return const Center(child: CircularProgressIndicator());
    }

    final ready = me.ready;
    final lobbyHasMinNumberOfPlayers = lobbyState.players.length >= lobbyMinNumberOfPlayers;

    return MenuWithBack(
      title: "Lobby",
      onBack: (ctx) => {
        adapter.leaveLobby(),
      },
      children: [
        if (lobbyState.message != null) ...[
          const SizedBox(height: 16),
          Text(lobbyState.message!),
        ],
        OutlinedButton.icon(
          onPressed: null,
          style: stealthBorder,
          icon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Icon(
              Icons.groups_2_sharp,
            ),
          ),
          label: Row(
            children: [
              Text("'${lobbyState.lobbyName}' lobby"),
            ],
          ),
        ),
        for (final player in lobbyState.players) ...{
          OutlinedButton.icon(
            onPressed: () {
              if (lobbyHasMinNumberOfPlayers && adapter.playerId == player.id) {
                adapter.readyToPlay(!ready);
              }
            },
            style: stealthBorder,
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Icon(
                adapter.playerId == player.id ? Icons.person_sharp : Icons.person_outline_sharp,
              ),
            ),
            label: Row(
              children: [
                Text(player.name + (adapter.playerId == player.name ? " (you)" : "")),
                const Spacer(),
                player.ready ? Icon(Icons.check_box_sharp) : Text("···"),
              ],
            ),
          ),
          const SizedBox(height: 8),
        },
        FilledOrOutlinedButton(
          filled: !lobbyHasMinNumberOfPlayers,
          onPressed: () {
            // TODO invite
          },
          style: stealthBorder,
          icon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Icon(Icons.add_sharp),
          ),
          label: Text("Invite others"),
        ),
        if (lobbyHasMinNumberOfPlayers) ...[
          const SizedBox(height: 16),
          FilledOrOutlinedButton(
            filled: !ready,
            onPressed: () {
              adapter.readyToPlay(!ready);
            },
            icon: Icon(Icons.check_sharp),
            label: Text(ready ? "You are ready..." : "Ready to play?"),
          ),
        ],
        const SizedBox(height: 24),
        OutlinedButton(
          style: stealthBorder,
          onPressed: () {
            adapter.leaveLobby();
          },
          child: const Text("Leave"),
        ),
      ],
    );
  }
}

class FilledOrOutlinedButton extends StatelessWidget {
  final bool filled;
  final Widget icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  const FilledOrOutlinedButton({
    super.key,
    required this.filled,
    required this.icon,
    required this.label,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: SizedBox(
        key: ValueKey(filled),
        width: double.infinity,
        child: filled
            ? FilledButton.icon(
                key: key,
                icon: icon,
                label: label,
                onPressed: onPressed,
              )
            : OutlinedButton.icon(
                key: key,
                icon: icon,
                label: label,
                style: style,
                onPressed: onPressed,
              ),
      ),
    );
  }
}

final ButtonStyle stealthBorder = ButtonStyle(
  side: WidgetStateBorderSide.resolveWith((states) {
    if (states.isEmpty) {
      return BorderSide(color: Colors.white.withOpacity(0));
    } else {
      return null;
    }
  }),
);

class PlayOnlineGameScreen extends StatefulWidget {
  const PlayOnlineGameScreen({super.key});

  @override
  State<PlayOnlineGameScreen> createState() => _PlayOnlineGameScreenState();
}

class _PlayOnlineGameScreenState extends State<PlayOnlineGameScreen> {
  OnlineGameProvider? onlineGameProvider;

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlinePlayProvider>(
      builder: (_, provider, __) {
        onlineGameProvider ??= OnlineGameProvider(provider);
        final lobbyState = provider.adapter!.lobbyState;

        switch (lobbyState) {
          case LobbyStatePlaying(gameState: final gameState):
            onlineGameProvider!.value = gameState;
            break;

          default:
            Navigator.of(context).popUntil((route) => route.isFirst);
            // TODO show error message
            break;
        }
        return ChangeNotifierProvider<GameStateProvider>.value(
            value: onlineGameProvider!, child: GameScreen());
      },
    );
  }
}
