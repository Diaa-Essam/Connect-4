import 'package:connect_four/model/algorithm.dart';
import 'package:connect_four/model/game_mode.dart';
import 'package:connect_four/presentation/ai_vs_ai_screen.dart';
import 'package:connect_four/presentation/benchmark_screen.dart';
import 'package:connect_four/presentation/game_screen.dart';
import 'package:flutter/material.dart';

class ModeSelectionScreen extends StatelessWidget {
  final Algorithm algorithm;
  final int kDepth;

  const ModeSelectionScreen({
    super.key,
    required this.algorithm,
    required this.kDepth,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
              const Text(
                "Select Mode",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${algorithm.name.toUpperCase()} | K=$kDepth",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 40),
              _modeButton(context, Icons.person, "Single Player (vs AI)", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      algorithm: algorithm,
                      kDepth: kDepth,
                      mode: GameMode.singlePlayer,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              _modeButton(context, Icons.group, "Two Players", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      algorithm: algorithm,
                      kDepth: kDepth,
                      mode: GameMode.twoPlayers,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              _modeButton(context, Icons.visibility, "AI vs AI (Visual)", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiVsAiScreen(
                      algorithm: algorithm,
                      kDepth: kDepth,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              _modeButton(context, Icons.speed, "AI vs AI (Benchmark)", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BenchmarkScreen(kDepth: kDepth),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: 260,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.white30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}