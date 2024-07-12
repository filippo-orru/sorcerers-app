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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        primarySwatch: Colors.blue,
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
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Sorcerers"),
          ),
          body: Column(
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
                  'Trump: ${game.trump}',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Lead: ${game.leadColor}',
                ),
              ),
              for (final card in game.currentPlayer.hand) ...{
                CardWidget(
                  card: card,
                  onTap: () {
                    game.playCard(game.currentPlayer, card);
                  },
                ),
              },
              if (winner != null) ...{
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Round winner: ${winner.name}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    game.initializeRound();
                  },
                  child: const Text('Next round'),
                ),
              }
            ],
          ),
        );
      },
    );
  }
}

class CardWidget extends StatelessWidget {
  final GameCard card;
  final void Function() onTap;

  const CardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: card.backgroundColor,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 150,
          padding: const EdgeInsets.all(8),
          child: Text(card.description),
        ),
      ),
    );
  }
}
