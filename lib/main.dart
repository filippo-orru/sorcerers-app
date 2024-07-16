import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sorcerers_app/online/online_game.dart';
import 'package:sorcerers_app/ui/local/play_local.dart';
import 'package:sorcerers_app/ui/online/play_online.dart';

void main() {
  runApp(const SorcerersApp());
}

class SorcerersApp extends StatelessWidget {
  const SorcerersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnlinePlayProvider(),
      lazy: false,
      child: MaterialApp(
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
              shape:
                  WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
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
      ),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LobbySelectionScreen()),
                    );
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
