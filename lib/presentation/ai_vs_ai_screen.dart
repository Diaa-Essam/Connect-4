import 'dart:async';
import 'package:connect_four/controller/game_controller.dart';
import 'package:connect_four/model/algorithm.dart';
import 'package:connect_four/presentation/app_button.dart';
import 'package:connect_four/presentation/min_max_tree.dart';
import 'package:flutter/material.dart';

class AiVsAiScreen extends StatefulWidget {
  final Algorithm algorithm;
  final int kDepth;
  const AiVsAiScreen({super.key, required this.algorithm, required this.kDepth});

  @override
  State<AiVsAiScreen> createState() => _AiVsAiScreenState();
}

class _AiVsAiScreenState extends State<AiVsAiScreen> {
  late GameController controller;
  bool isRunning = false;
  Duration totalComputeTime = Duration.zero;
  int totalNodes = 0;
  // Bug 4 fix: incremented on every (re)start so any older loop iteration
  // detects it is stale and exits, preventing two concurrent game loops.
  int _loopGeneration = 0;

  @override
  void initState() {
    super.initState();
    controller = GameController(algorithm: widget.algorithm, kDepth: widget.kDepth);
    _startGame();
  }

  Future<void> _startGame() async {
    // Bug 4 fix: capture the generation for this run; if _loopGeneration
    // changes (because Replay was pressed), this loop will self-exit.
    final int myGeneration = ++_loopGeneration;

    setState(() => isRunning = true);
    totalComputeTime = Duration.zero;
    totalNodes = 0;

    while (!controller.isGameOver) {
      // Bug 4 fix: bail out if a newer loop has been started
      if (_loopGeneration != myGeneration) return;

      final sw = Stopwatch()..start();
      final result = controller.ai.getBestMove(controller.board, controller.currentPlayer);
      sw.stop();

      totalComputeTime += result.elapsedTime;
      totalNodes += result.nodesExpanded;
      controller.lastMinimaxTree = result.root;
      controller.lastNodesExpanded = result.nodesExpanded;
      controller.lastAiTime = result.elapsedTime;

      print("=== AI vs AI TURN (Player ${controller.currentPlayer}) ===");

      controller.makeMove(result.column);

      // Bug 2 fix: guard setState after synchronous work too, in case the
      // widget was disposed between getBestMove returning and here.
      if (!mounted) return;
      setState(() {});

      // Visual delay so user can watch
      await Future.delayed(const Duration(milliseconds: 600));

      // Bug 2 fix: widget may have been disposed during the delay
      if (!mounted) return;
    }

    // Bug 4 fix: a stale loop must not update state or show the dialog
    if (_loopGeneration != myGeneration) return;

    // Bug 2 fix: check mounted before calling setState and showDialog
    if (!mounted) return;
    setState(() => isRunning = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Game Finished", style: TextStyle(color: Colors.white)),
        content: Text(
          "Winner: ${controller.scorePlayer1 > controller.scorePlayer2 ? 'RED' : controller.scorePlayer2 > controller.scorePlayer1 ? 'YELLOW' : 'DRAW'}\n\n"
          "Red Connections: ${controller.scorePlayer1}\n"
          "Yellow Connections: ${controller.scorePlayer2}\n\n"
          "Total Compute Time: ${totalComputeTime.inMilliseconds} ms\n"
          "Total Nodes Expanded: $totalNodes\n"
          "Algorithm: ${widget.algorithm.name}\n"
          "Depth K: ${widget.kDepth}",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Bug 4 fix: resetGame first, then _startGame increments
              // _loopGeneration, causing any still-running old loop to exit.
              controller.resetGame();
              _startGame();
            },
            child: const Text("Replay", style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text("Home", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "AI vs AI — ${widget.algorithm.name}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.isGameOver ? "FINISHED" : (isRunning ? "THINKING..." : "READY"),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(radius: 10, backgroundColor: Colors.red),
                      const SizedBox(width: 10),
                      Text("${controller.scorePlayer1}", style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 30),
                      const CircleAvatar(radius: 10, backgroundColor: Colors.yellow),
                      const SizedBox(width: 10),
                      Text("${controller.scorePlayer2}", style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildBoard(),
                  if (controller.lastMinimaxTree != null) ...[
                    const SizedBox(height: 10),
                    MinimaxTreeWidget(root: controller.lastMinimaxTree!),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Turn Nodes: ${controller.lastNodesExpanded} | Turn Time: ${controller.lastAiTime.inMilliseconds}ms",
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (controller.isGameOver)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "TOTAL Time: ${totalComputeTime.inMilliseconds}ms | TOTAL Nodes: $totalNodes",
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 10),
                  AppButton(
                    icon: Icons.home,
                    label: "Menu",
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      width: MediaQuery.of(context).size.width - 28,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 5))],
      ),
      child: GridView.builder(
        itemCount: 42,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
        itemBuilder: (context, index) {
          int row = index ~/ 7;
          int col = index % 7;
          int cell = controller.board.grid[row][col];
          Color color;
          if (cell == 1) {
            color = Colors.red;
          } else if (cell == 2) color = Colors.yellow;
          else color = const Color(0xFFE5E7EB);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                if (cell != 0)
                  BoxShadow(
                    color: (cell == 1 ? Colors.red : Colors.yellow).withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}