import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sorcerers_app/game/providers/local_game_provider.dart';
import 'package:sorcerers_app/ui/game_screen.dart';
import 'package:sorcerers_app/ui/widget_utils.dart';

class PlayerNamesScreen extends StatefulWidget {
  const PlayerNamesScreen({super.key});

  @override
  State<PlayerNamesScreen> createState() => _PlayerNamesScreenState();
}

class _PlayerNamesScreenState extends State<PlayerNamesScreen> {
  final List<String> playerNames = ["filippo", "nici", "senfti"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaxWidth(
        maxWidth: 400,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                "Who's playing?",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              for (final (index, player) in playerNames.indexed) ...{
                PlayerNameField(
                  key: ValueKey(index),
                  player: player,
                  onChanged: (value) {
                    setState(() {
                      playerNames[index] = value;
                    });
                  },
                  onAddNewPlayer: () {
                    setState(() {
                      playerNames.add("");
                    });
                  },
                  onRemove: () {
                    setState(() {
                      playerNames.removeAt(index);
                    });
                  },
                  onPlay: () {
                    startPlaying(context);
                  },
                ),
              },
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    playerNames.add("");
                  });
                },
                label: SizedBox(),
                icon: Icon(Icons.add),
              ),
              const SizedBox(height: 64),
              OutlinedButton.icon(
                onPressed: playerNames.isNotEmpty
                    ? () {
                        startPlaying(context);
                      }
                    : null,
                label: Text("Start game"),
                icon: Icon(Icons.play_arrow_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startPlaying(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          provider: LocalGameProvider(playerNames),
        ),
      ),
    );
  }
}

class PlayerNameField extends StatefulWidget {
  final String player;
  final void Function(String) onChanged;
  final VoidCallback onAddNewPlayer;
  final VoidCallback onRemove;
  final VoidCallback onPlay;

  const PlayerNameField({
    super.key,
    required this.player,
    required this.onChanged,
    required this.onAddNewPlayer,
    required this.onRemove,
    required this.onPlay,
  });

  @override
  State<PlayerNameField> createState() => _PlayerNameFieldState();
}

class _PlayerNameFieldState extends State<PlayerNameField> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.player);
    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (controller.text.isEmpty && event.logicalKey == LogicalKeyboardKey.backspace) {
            widget.onRemove();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );
  }

  @override
  void didUpdateWidget(covariant PlayerNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player != widget.player) {
      controller.text = widget.player;
      controller.selection = TextSelection.collapsed(offset: widget.player.length);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shortcuts(
        shortcuts: {
          SingleActivator(
            LogicalKeyboardKey.enter,
            control: defaultTargetPlatform != TargetPlatform.macOS,
            meta: defaultTargetPlatform == TargetPlatform.macOS,
          ): CommandEnterIntent(),
        },
        child: Actions(
          actions: {
            CommandEnterIntent: CallbackAction(onInvoke: (_) => widget.onPlay()),
          },
          child: TextField(
            autofocus: true,
            focusNode: focusNode,
            controller: controller,
            onChanged: (value) => widget.onChanged(value),
            onSubmitted: (_) => widget.onAddNewPlayer(),
            onTapOutside: (event) {
              focusNode.unfocus();
            },
            decoration: const InputDecoration(
              hintText: "Player name",
            ),
          ),
        ),
      ),
    );
  }
}
