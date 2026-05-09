import 'package:connect_four/controller/game_controller.dart';
import 'package:connect_four/model/algorithm.dart';
import 'package:flutter/material.dart';

class BenchmarkScreen extends StatefulWidget {
  final int kDepth;
  const BenchmarkScreen({super.key, required this.kDepth});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  bool isRunning = true;
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _runBenchmarks();
  }

  Future<void> _runBenchmarks() async {
    for (final algo in Algorithm.values) {
      final result = await GameController.runBenchmarkGame(algo, widget.kDepth);
      setState(() => results.add(result));
    }
    setState(() => isRunning = false);
  }

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
            child: isRunning
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text("Running algorithms in background...", style: TextStyle(color: Colors.white)),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          "Benchmark Results",
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Depth K = ${widget.kDepth}",
                          style: const TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ...results.map((r) => _resultCard(r)),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.home, color: Colors.white),
                          label: const Text("Back to Menu", style: TextStyle(color: Colors.white)),
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _resultCard(Map<String, dynamic> r) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r['algorithm'].toString().toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _row("Time", "${r['timeMs']} ms"),
          _row("Total Nodes Expanded", "${r['totalNodes']}"),
          _row("Total Moves", "${r['moves']}"),
          _row("Red Score", "${r['score1']}"),
          _row("Yellow Score", "${r['score2']}"),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}