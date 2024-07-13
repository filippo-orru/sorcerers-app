import 'dart:math';

import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';
import 'package:provider/provider.dart';
import 'package:sorcerers_app/extensions.dart';
import 'package:sorcerers_app/logic/game.dart';

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
  final List<String> players = ["filippo", "nici", "senfti"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
              for (final (index, player) in players.indexed) ...{
                PlayerNameField(
                  player: player,
                  onChanged: (value) {
                    setState(() {
                      players[index] = value;
                    });
                  },
                ),
              },
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    players.add("");
                  });
                },
                label: SizedBox(),
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: players.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(players: players),
                  ),
                );
              }
            : null,
        tooltip: 'Play',
        child: const Icon(Icons.play_arrow_rounded),
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
  final List<String> players;

  const GameScreen({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Game>(
      create: (context) => Game(players),
      child: const GameWidget(),
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
    return Consumer<Game>(
      builder: (_, game, __) {
        final Player currentPlayer;
        if (game.roundState == RoundState.predictScore) {
          currentPlayer =
              game.players.firstWhere((player) => !game.roundScores.containsKey(player));
        } else {
          currentPlayer = game.currentPlayer;
        }

        return Scaffold(
          body: LocalHeroScope(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Stack(
              children: [
                SafeArea(
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
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.yellow),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: CardContent(card: game.trump, onTap: () {}, scale: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              children: game.players
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
                                duration: Duration(milliseconds: 800),
                                height: currentPlayer.hand.isNotEmpty ? 150 : 32,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for (final (i, card) in currentPlayer.hand.indexed) ...[
                                      LocalHero(
                                        tag: card.description,
                                        child: CardContent(
                                          card: card,
                                          onTap: game.roundState == RoundState.playing &&
                                                  game.cardsOnTable.length < game.players.length &&
                                                  currentPlayer.canPlayCard(card, game.leadColor)
                                              ? () {
                                                  game.playCard(currentPlayer, card);
                                                }
                                              : null,
                                        ),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: showMenu
                      ? Center(
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
                                    game.stop();
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  },
                                  child: const Text('Stop playing'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Instructions extends StatelessWidget {
  const Instructions({
    super.key,
    required this.currentPlayer,
  });

  final Player currentPlayer;

  @override
  Widget build(BuildContext context) {
    return Consumer<Game>(
      builder: (_, game, __) {
        final bool isBidding = game.roundState == RoundState.predictScore;
        final bool isFinished = game.roundState == RoundState.finished;
        final bool isTrickFinished = game.cardsOnTable.length == game.players.length;

        final bool chooseTrumpColor = game.mustChooseTrumpColor && game.trumpColor == null;
        // final bool chooseTrumpColorMe = true; // TODO

        final bool important = isBidding || isFinished || isTrickFinished;

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
            key: ValueKey(game.roundState.toString() + isTrickFinished.toString()),
            children: [
              if (isTrickFinished) ...[
                Text(
                  "${game.getTrickWinner()!.name} won this trick!",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    game.readyForNextTrick();
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
                    game.startNewRound(incrementRound: true);
                  },
                  child: const Text('Next round'),
                ),
              ] else if (game.roundState == RoundState.predictScore) ...[
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
                          child: GestureDetector(
                            onTap: () {
                              game.setBid(currentPlayer, i);
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: Colors.white.withOpacity(.1),
                              ),
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
              ] else if (chooseTrumpColor) ...[
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
                              game.trumpColor = color;
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
              ] else if (game.roundState == RoundState.playing) ...[
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
    return Consumer<Game>(builder: (_, game, __) {
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
          for (final player in game.players) ...[
            TableRow(
              children: buildCells(player, game),
            ),
          ],
        ],
      );
    });
  }

  List<TableCell> buildCells(Player player, Game game) {
    final roundScore = game.roundScores[player];
    final totalPoints = game.gameScore.getTotalPointsFor(player);
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
            "${roundScore.currentScore}/${roundScore.predictedScore}",
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
  final Player player;
  final bool isActive;

  const PlayerOnTable(this.player, {super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Consumer<Game>(
      builder: (_, game, __) {
        final score = game.roundScores[player];
        final cardOnTable =
            game.cardsOnTable.where((cardOnTable) => cardOnTable.player == player).firstOrNull;
        final isStrongestCard = cardOnTable != null && game.getStrongestCard() == cardOnTable;

        return Center(
          child: SizedBox(
            width: 100,
            height: 150,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(player.name),
                    if (score != null) ...{
                      Text("${score.currentScore}/${score.predictedScore}"),
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
                                ? LocalHero(
                                    tag: cardOnTable.card.description,
                                    child: CardContent(
                                      card: cardOnTable.card,
                                      onTap: () {},
                                    ),
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
