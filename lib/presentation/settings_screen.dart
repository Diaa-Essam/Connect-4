import 'package:connect_four/model/algorithm.dart';
import 'package:connect_four/presentation/mode_selection_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Algorithm selectedAlgorithm = Algorithm.minimaxAlphaBeta;
  int kDepth = 4;

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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Connect Four AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Algorithm",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ...Algorithm.values.map((algo) => RadioListTile<Algorithm>(
                          title: Text(
                            algo == Algorithm.minimax
                                ? "Minimax"
                                : algo == Algorithm.minimaxAlphaBeta
                                    ? "Minimax + Alpha-Beta"
                                    : "Expected Minimax",
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: algo,
                          groupValue: selectedAlgorithm,
                          onChanged: (v) => setState(() => selectedAlgorithm = v!),
                          activeColor: Colors.blueAccent,
                        )),
                        const Divider(color: Colors.white24),
                        const Text(
                          "Search Depth (K)",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Slider(
                          value: kDepth.toDouble(),
                          min: 2,
                          max: 7,
                          divisions: 5,
                          label: "$kDepth",
                          activeColor: Colors.blueAccent,
                          inactiveColor: Colors.white24,
                          onChanged: (v) => setState(() => kDepth = v.round()),
                        ),
                        Center(
                          child: Text(
                            "K = $kDepth",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 260,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      label: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ModeSelectionScreen(
                              algorithm: selectedAlgorithm,
                              kDepth: kDepth,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}