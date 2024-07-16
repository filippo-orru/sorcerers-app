import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sorcerers_app/extensions.dart';
import 'package:sorcerers_app/game/cards.dart';
import 'package:sorcerers_app/game/game.dart';
import 'package:sorcerers_app/game/providers/local_game_provider.dart';
import 'package:sorcerers_app/messages/game_messages/game_messages_client.dart';

void main() {
  runApp(const SorcerersApp());
}

class SorcerersApp extends StatelessWidget {
  const SorcerersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorcerers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
          surface: Colors.black,
          primary: Colors.white,
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Text(
                    "Sorcerers",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PlayerNamesScreen()),
                    );
                  },
                  label: Text("Play on this device"),
                  icon: Icon(Icons.play_arrow_rounded),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(builder: (context) => PlayerNamesScreen()),
                    // );
                  },
                  label: Text("Play online"),
                  icon: Icon(Icons.play_arrow_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
                  player: player,
                  onChanged: (value) {
                    setState(() {
                      playerNames[index] = value;
                    });
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              provider: LocalGameProvider(playerNames),
                            ),
                          ),
                        );
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
}

class PlayerNameField extends StatefulWidget {
  final String player;
  final void Function(String) onChanged;

  const PlayerNameField({super.key, required this.player, required this.onChanged});

  @override
  State<PlayerNameField> createState() => _PlayerNameFieldState();
}

class _PlayerNameFieldState extends State<PlayerNameField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.player);
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
      child: TextField(
        controller: controller,
        onChanged: (value) => widget.onChanged(value),
        onSubmitted: null, // TODO
        decoration: const InputDecoration(
          hintText: "Player name",
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final GameStateProvider provider;

  const GameScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<GameStateProvider>.value(
        value: provider,
        child: const GameWidget(),
      ),
    );
  }
}

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  bool showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (_, gameStateProvider, __) {
        final game = gameStateProvider.value;
        final currentPlayer = game.players[game.currentPlayerId]!;

        return Stack(
          children: [
            MaxWidth(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Stack(
                          children: [
                            Center(
                              child: OutlinedButton.icon(
                                // padding: const EdgeInsets.all(8),
                                // decoration: BoxDecoration(
                                //   color: Theme.of(context).colorScheme.surfaceContainerLow,
                                //   border: Border.all(
                                //       color:
                                //           Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                // ),
                                onPressed: () {
                                  setState(() {
                                    showMenu = true;
                                  });
                                },
                                label: Text(
                                  "Round ${game.cardsForRound}",
                                ),
                                icon: Icon(Icons.menu_rounded),
                              ),
                            ),
                            if (game.trump != null) ...{
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.yellow),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: CardContent(card: game.trump!, onTap: () {}, scale: 0.5),
                                ),
                              ),
                            }
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: GridView.count(
                            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: game.players.values
                                .map((player) => PlayerOnTable(
                                      player,
                                      isActive: player == currentPlayer,
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      Instructions(currentPlayer: currentPlayer),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          border: Border(
                            left: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            right: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: currentPlayer.hand.isNotEmpty ? 150 : 32,
                              child: ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (final (i, card) in currentPlayer.hand.indexed) ...[
                                    CardContent(
                                      card: card,
                                      onTap: game.roundStage == RoundStage.playing &&
                                              game.cardsOnTable.length < game.players.length &&
                                              currentPlayer.canPlayCard(card, game.leadColor)
                                          ? () {
                                              game.sendIntent(PlayCard(card));
                                            }
                                          : null,
                                    ),
                                    if (i < currentPlayer.hand.length - 1) ...{
                                      const SizedBox(width: 8),
                                    }
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: showMenu
                  ? ModalBarrier(
                      key: ValueKey("Modal"),
                      dismissible: true,
                      onDismiss: () {
                        setState(() {
                          showMenu = false;
                        });
                      },
                      color: Theme.of(context).colorScheme.scrim.withOpacity(0.75))
                  : const SizedBox(),
            ),
            MaxWidth(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: showMenu
                    ? Actions(
                        actions: {
                          DismissIntent: CallbackAction(
                            onInvoke: (_) => setState(
                              () => showMenu = false,
                            ),
                          ),
                        },
                        child: Focus(
                          autofocus: true,
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerLow,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Round ${game.cardsForRound}",
                                          style: Theme.of(context).textTheme.titleLarge),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showMenu = false;
                                          });
                                        },
                                        icon: Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ScoresTable(),
                                  const Divider(height: 32),
                                  OutlinedButton(
                                    onPressed: () {
                                      game.sendIntent(LeaveGame());
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    },
                                    child: const Text('Stop playing'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidth({super.key, required this.child, this.maxWidth = 600});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class Instructions extends StatelessWidget {
  const Instructions({
    super.key,
    required this.currentPlayer,
  });

  final PlayerState currentPlayer;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (_, gameStateProvider, __) {
        final game = gameStateProvider.value;

        final bool isShuffle = game.roundStage == RoundStage.shuffle;
        final bool mustChooseTrumpColor = game.roundStage == RoundStage.mustChooseTrumpColor;
        final bool isBidding = game.roundStage == RoundStage.bidding;
        final bool isFinished = game.roundStage == RoundStage.finished;
        final bool isTrickFinished = game.cardsOnTable.length == game.players.length;

        // final bool chooseTrumpColorMe = true; // TODO

        final bool important = isShuffle || isBidding || isFinished || isTrickFinished;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: important
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surfaceContainerLow,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            key: ValueKey(game.roundStage.toString() + isTrickFinished.toString()),
            children: [
              if (isTrickFinished) ...[
                Text(
                  "${game.players[game.getTrickWinner()!]!.name} won this trick!",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    game.sendIntent(ReadyForNextTrick());
                  },
                  child: const Text('Continue'),
                ),
              ] else if (isFinished) ...[
                Text(
                  "The round is over",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 16),
                ScoresTable(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    game.sendIntent(StartNewRound());
                  },
                  child: const Text('Next round'),
                ),
              ] else if (isShuffle) ...[
                const Text(
                  "Shuffle the deck",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      game.sendIntent(ShuffleDeck());
                    },
                    child: Text("Shuffle"),
                  ),
                ),
              ] else if (isBidding) ...[
                const Text(
                  "Bid your tricks",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        game.cardsForRound + 1, // +1 for 0
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: OutlinedButton(
                              style: ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                alignment: Alignment.center,
                              ),
                              onPressed: () {
                                game.sendIntent(SetBid(i));
                              },
                              child: Text(
                                "$i",
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (mustChooseTrumpColor) ...[
                const Text(
                  "Pick the trump color",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  children: CardColor.values
                      .map(
                        (color) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              game.sendIntent(SetTrumpColor(color));
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: color.color,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ] else if (game.roundStage == RoundStage.playing) ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pick a card", // TODO support "not my turn"
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class ScoresTable extends StatelessWidget {
  const ScoresTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (_, gameStateProvider, __) {
        final game = gameStateProvider.value;
        return Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              children: [
                TableCell(
                  child: Text(
                    "Player".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TableCell(
                  child: Text(
                    "Tricks".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TableCell(
                  child: Text(
                    "Points".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: const [
                SizedBox(height: 8),
                SizedBox(height: 8),
                SizedBox(height: 8),
              ],
            ),
            for (final player in game.players.values) ...[
              TableRow(
                children: buildCells(player, game),
              ),
            ],
          ],
        );
      },
    );
  }

  List<TableCell> buildCells(PlayerState player, GameState game) {
    final roundScore = game.roundScores[player.id];
    final totalPoints = game.gameScore.getTotalPointsFor(player.id);
    if (roundScore == null) {
      return [
        TableCell(child: Text(player.name)),
        TableCell(child: Text("?")),
        TableCell(child: Text("$totalPoints")),
      ];
    } else {
      return [
        TableCell(child: Text(player.name)),
        TableCell(
          child: Text(
            "${roundScore.currentScore}/${roundScore.bid}",
          ),
        ),
        TableCell(
          child: Text(
            "${totalPoints + roundScore.getPoints()} (${roundScore.getPoints().withSign()})",
          ),
        )
      ];
    }
  }
}

class CardContent extends StatelessWidget {
  const CardContent({
    super.key,
    required this.card,
    required this.onTap,
    this.scale = 1,
  });

  final GameCard card;
  final void Function()? onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: card.backgroundColor.withOpacity(onTap != null ? 1 : 0.5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 100 * scale,
          height: 150 * scale,
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            card.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class PlayerOnTable extends StatelessWidget {
  final PlayerState player;
  final bool isActive;

  const PlayerOnTable(this.player, {super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (_, gameStateProvider, __) {
        final game = gameStateProvider.value;

        final score = game.roundScores[player.id];
        final cardOnTable =
            game.cardsOnTable.where((cardOnTable) => cardOnTable.playerId == player.id).firstOrNull;
        final isStrongestCard = cardOnTable != null && game.getStrongestCard() == cardOnTable;

        return Center(
          child: AspectRatio(
            aspectRatio: 100 / 150,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(player.name),
                    if (score != null) ...{
                      Text("${score.currentScore}/${score.bid}"),
                    } else ...{
                      const SizedBox(),
                    },
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    // height: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    child: OverflowBox(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerLow,
                              border: isActive
                                  ? Border.all(
                                      color:
                                          Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    )
                                  : null,
                            ),
                            child: cardOnTable != null
                                ? CardContent(
                                    card: cardOnTable.card,
                                    onTap: () {},
                                  )
                                : const SizedBox.expand(),
                          ),
                          if (isStrongestCard) ...{
                            Positioned(
                              bottom: -5,
                              right: -5,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Transform.rotate(
                                  angle: pi * -0.25,
                                  child: Icon(
                                    Icons.open_with_rounded,
                                    color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          }
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
