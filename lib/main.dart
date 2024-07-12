import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sorcerers_app/logic/game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        useMaterial3: true,
      ),
      home: const PlayerNamesPage(),
    );
  }
}

class PlayerNamesPage extends StatefulWidget {
  const PlayerNamesPage({super.key});

  @override
  State<PlayerNamesPage> createState() => _PlayerNamesPageState();
}

class _PlayerNamesPageState extends State<PlayerNamesPage> {
  final List<String> players = ["filippo", "nici"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Sorcerers"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Who\'s playing?',
                style: TextStyle(fontSize: 24),
              ),
              for (final (index, player) in players.indexed) ...{
                PlayerNameField(
                  player: player,
                  onChanged: (value) {
                    setState(() {
                      players[index] = value;
                    });
                  },
                ),
              }
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
                    builder: (context) => GamePage(players: players),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        controller: controller,
        onChanged: (value) => widget.onChanged(value),
        onSubmitted: null, // TODO
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Player name",
        ),
      ),
    );
  }
}

class GamePage extends StatelessWidget {
  final List<String> players;

  const GamePage({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Game>(
      create: (context) => Game(players),
      child: const GamePageInternal(),
    );
  }
}

class GamePageInternal extends StatelessWidget {
  const GamePageInternal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Game>(
      builder: (_, game, __) {
        final winner = game.getRoundWinner();

        return Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Your turn, ${game.currentPlayer.name}!',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Lead: ${game.leadColor}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CardWidget(
                            card: game.trump,
                            isDeck: true,
                            onTap: () {},
                          ),
                          for (final card in game.cardsOnTable) ...{
                            CardWidget(
                              card: card.card,
                              onTap: () {},
                            ),
                          },
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final card in game.currentPlayer.hand) ...{
                            CardWidget(
                              card: card,
                              onTap: game.currentPlayer.canPlayCard(card, game.leadColor)
                                  ? () {
                                      game.playCard(game.currentPlayer, card);
                                    }
                                  : null,
                            ),
                          },
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: winner != null ? const ModalBarrier() : const SizedBox(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: winner != null
                    ? Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Winner",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    winner.name,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    game.roundNumber += 1;
                                    game.initializeRound();
                                  },
                                  child: const Text('Next round'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardWidget extends StatelessWidget {
  final GameCard card;
  final void Function()? onTap;
  final bool isDeck;

  const CardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.isDeck = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDeck ? Colors.yellow : Colors.transparent,
            width: isDeck ? 2 : 0,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Material(
          color: card.backgroundColor.withOpacity(onTap != null ? 1 : 0.5),
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 100,
              height: 150,
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                card.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
