import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorcerers_app/online/online_game.dart';
import 'package:sorcerers_app/ui/local/play_local.dart';
import 'package:sorcerers_app/ui/online/play_online.dart';

SharedPreferences? _globalPrefs;
SharedPreferences get globalPrefs => _globalPrefs!;

void main() {
  runApp(const SorcerersApp());
}

class SorcerersApp extends StatelessWidget {
  const SorcerersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (_, snapshot) {
        final prefs = snapshot.data;
        if (prefs != null) {
          _globalPrefs ??= prefs;
        }

        return snapshot.connectionState != ConnectionState.done
            ? const SizedBox()
            : ChangeNotifierProvider(
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
                    filledButtonTheme: FilledButtonThemeData(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                      ),
                    ),
                    outlinedButtonTheme: OutlinedButtonThemeData(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
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
      },
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
            width: 300,
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
                SizedBox(height: 48),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PlayerNamesScreen()),
                    );
                  },
                  label: Text("Play on this device"),
                  icon: Icon(Icons.play_arrow_outlined),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => OnlinePlayWrapper()),
                    );
                  },
                  label: Text("Play online"),
                  icon: Icon(Icons.public_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
