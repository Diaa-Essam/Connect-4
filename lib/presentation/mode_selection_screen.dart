import 'package:flutter/material.dart';
import '../model/game_mode.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(mode: GameMode.singlePlayer),
                  ),
                );
              },
              child: const Text("Single Player"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(mode: GameMode.twoPlayers),
                  ),
                );
              },
              child: const Text("Two Players"),
            ),
          ],
        ),
      ),
    );
  }
}
