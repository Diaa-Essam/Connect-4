import 'package:connect_four/presentation/app_button.dart';
import 'package:flutter/material.dart';
import '../model/game_mode.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Connect Four",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Choose a mode to start",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 40),

              AppButton(
                icon: Icons.person,
                label: "Single Player",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(mode: GameMode.singlePlayer),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              AppButton(
                icon: Icons.group,
                label: "Two Players",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(mode: GameMode.twoPlayers),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
