import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sorcerers_app/game/providers/online_game_provider.dart';
import 'package:sorcerers_app/ui/game_screen.dart';

import 'package:sorcerers_core/online/messages/messages_server.dart';
import 'package:sorcerers_app/online/online_game.dart';
import 'package:sorcerers_app/ui/widget_utils.dart';

class OnlinePlayWrapper extends StatefulWidget {
  const OnlinePlayWrapper({super.key});

  @override
  State<OnlinePlayWrapper> createState() => _OnlinePlayWrapperState();
}

class _OnlinePlayWrapperState extends State<OnlinePlayWrapper> {
  Widget buildContent(LobbyState? lobbyState) {
    return switch (lobbyState) {
      null => NameSelectionScreen(key: ValueKey("name")),
      LobbyStateIdle() => LobbySelectionScreen(key: ValueKey("idle"), lobbyState: lobbyState),
      LobbyStateInLobby() => InLobbyScreen(key: ValueKey("inLobby"), lobbyState: lobbyState),
      LobbyStatePlaying() => PlayOnlineGameScreen(key: ValueKey("playing"))
    };
  }

  final curveTween = CurveTween(curve: Curves.easeOutQuad);

  @override
  Widget build(BuildContext context) {
    return RequireConnection(
      child: Consumer<OnlinePlayProvider>(
        builder: (_, provider, __) {
          final lobbyState = provider.lobbyState;
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                key: ValueKey<Key?>(child.key),
                opacity: animation.drive(curveTween),
                child: child,
              );
            },
            child: buildContent(lobbyState),
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
        void setName() {
          final value = _nameEditingController.text;
          if (value.length <= 3) {
            setState(() {
              _nameMustBeLonger = true;
            });
            return;
          }
          provider.storedName = value;
          provider.sendNewName();
        }

        if (provider.storedName == null) {
          return MenuWithBack(
            title: const Text("What's your name?"),
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
                "Only alphanumeric characters are allowed. This name will be visible to other players.",
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
  final LobbyStateIdle lobbyState;

  const LobbySelectionScreen({super.key, required this.lobbyState});

  @override
  State<LobbySelectionScreen> createState() => _LobbySelectionScreenState();
}

class _LobbySelectionScreenState extends State<LobbySelectionScreen> {
  bool _triedCreatingShortName = false;

  TextEditingController? _newLobbyNameController;
  final FocusNode _newLobbyNameFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlinePlayProvider>(
      builder: (_, provider, __) {
        return MenuWithBack(
          title: Text("Select a lobby", style: TextStyle(fontSize: 24)),
          children: [
            if (widget.lobbyState.lobbies.isNotEmpty) ...{
              for (final lobby in widget.lobbyState.lobbies) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    provider.joinLobby(lobby.name);
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
            } else if (_newLobbyNameController == null) ...{
              Text("No lobbies available, create one instead!"),
            },
            const SizedBox(height: 16),
            if (_newLobbyNameController == null) ...[
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _newLobbyNameController = TextEditingController());
                },
                icon: const Icon(Icons.add),
                label: const Text("Create a new lobby"),
              )
            ] else ...[
              const SizedBox(height: 16),
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
                    return Text("");
                  }
                },
                onSubmitted: (value) {
                  provider.createLobby(value);
                  setState(() => _newLobbyNameController = null);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  if (_newLobbyNameController!.text.length <= 3) {
                    setState(() => _triedCreatingShortName = true);
                    _newLobbyNameFocus.requestFocus();
                    return;
                  }
                  setState(() => _triedCreatingShortName = false);

                  provider.createLobby(_newLobbyNameController!.text);
                  setState(() => _newLobbyNameController = null);
                },
                child: const Text("Create lobby"),
              ),
            ],
          ],
        );
      },
    );
  }
}

class MenuWithBack extends StatelessWidget {
  final Widget title;
  final List<Widget> children;
  final void Function(BuildContext) onBack;

  const MenuWithBack({
    super.key,
    required this.title,
    required this.children,
    void Function(BuildContext)? onBack,
  }) : onBack = onBack ?? _defaultOnBack;

  static void _defaultOnBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MaxWidth(
            maxWidth: 400 + 48 * 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => onBack(context),
                          ),
                        ),
                      ),
                      title,
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        if (provider.connection.okay) {
          context.read<OnlinePlayProvider>().sendNewName();

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
                              provider.leaveLobby();
                              Navigator.of(context).popUntil((r) => r.isFirst);
                            },
                            child: Text("Leave"))
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
    final provider = context.watch<OnlinePlayProvider>();

    var me = lobbyState.players.firstWhere((player) => player.name == lobbyState.myName);
    final ready = me.ready;
    final isAlone = lobbyState.players.length == 1;

    return MenuWithBack(
      title: const Text(
        "Ready to play?",
        style: TextStyle(fontSize: 18),
      ),
      onBack: (ctx) => {
        provider.leaveLobby(),
      },
      children: [
        const SizedBox(height: 16),
        for (final player in lobbyState.players) ...{
          OutlinedButton.icon(
            onPressed: () {
              if (lobbyState.myName == player.name) {
                provider.readyToPlay(!ready);
              }
            },
            style: stealthBorder,
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Icon(
                lobbyState.myName == player.name ? Icons.person_sharp : Icons.person_outline_sharp,
              ),
            ),
            label: Row(
              children: [
                Text(player.name + (lobbyState.myName == player.name ? " (you)" : "")),
                const Spacer(),
                player.ready ? Icon(Icons.check_box_sharp) : Text("···"),
              ],
            ),
          ),
          const SizedBox(height: 8),
        },
        FilledOrOutlinedButton(
          filled: isAlone,
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
        const SizedBox(height: 16),
        FilledOrOutlinedButton(
          filled: !isAlone && !ready,
          onPressed: () {
            provider.readyToPlay(!ready);
          },
          icon: Icon(Icons.check_sharp),
          label: Text(ready ? "You are ready, waiting for others..." : "Ready to play?"),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          style: stealthBorder,
          onPressed: () {
            context.read<OnlinePlayProvider>().leaveLobby();
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

class PlayOnlineGameScreen extends StatelessWidget {
  const PlayOnlineGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<OnlinePlayProvider, OnlineGameProvider>(
      create: (context) =>
          OnlineGameProvider(Provider.of<OnlinePlayProvider>(context, listen: false)),
      update: (context, onlinePlayProvider, onlineGameProvider) {
        final lobbyState = onlinePlayProvider.lobbyState;
        onlineGameProvider!;

        switch (lobbyState) {
          case LobbyStatePlaying(gameState: final gameState):
            onlineGameProvider.value = gameState;
            break;

          default:
            Navigator.of(context).popUntil((route) => route.isFirst);
            // TODO show error message
            break;
        }
        return onlineGameProvider;
      },
      child: GameScreen(),
    );
  }
}
