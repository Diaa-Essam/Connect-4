import 'package:connect_four/controller/game_controller.dart';
import 'package:connect_four/model/algorithm.dart';
import 'package:connect_four/model/game_mode.dart';
import 'package:connect_four/presentation/app_button.dart';
import 'package:connect_four/presentation/min_max_tree.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final Algorithm algorithm;
  final int kDepth;
  final GameMode mode;
  const GameScreen({
    super.key,
    required this.algorithm,
    required this.kDepth,
    required this.mode,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;
  int? pressedIndex;

  @override
  void initState() {
    super.initState();
    controller = GameController(
      algorithm: widget.algorithm,
      kDepth: widget.kDepth,
    );
  }

  /// Block input when game is over, during AI turn in single-player, or in AI-vs-AI modes.
  bool get _inputBlocked {
    if (controller.isGameOver) return true;
    if (widget.mode == GameMode.singlePlayer && controller.currentPlayer != 1) {
      return true;
    }
    if (widget.mode == GameMode.aiVsAiVisual ||
        widget.mode == GameMode.aiVsAiBenchmark) {
      return true;
    }
    return false;
  }

  String get _modeTitle {
    switch (widget.mode) {
      case GameMode.singlePlayer:
        return "Single Player";
      case GameMode.twoPlayers:
        return "Two Players";
      case GameMode.aiVsAiVisual:
      case GameMode.aiVsAiBenchmark:
        return "AI vs AI";
    }
  }

  String get _turnText {
    if (controller.isGameOver) {
      if (controller.scorePlayer1 > controller.scorePlayer2) return "RED WINS";
      if (controller.scorePlayer2 > controller.scorePlayer1) {
        return "YELLOW WINS";
      }
      return "DRAW";
    }
    switch (widget.mode) {
      case GameMode.twoPlayers:
        return controller.currentPlayer == 1 ? "PLAYER 1" : "PLAYER 2";
      case GameMode.singlePlayer:
        return controller.currentPlayer == 1 ? "YOUR TURN" : "AI THINKING...";
      case GameMode.aiVsAiVisual:
      case GameMode.aiVsAiBenchmark:
        return "AI THINKING...";
    }
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
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildScoreRow(),
                  const SizedBox(height: 10),
                  _buildBoard(),
                  if (controller.lastMinimaxTree != null) ...[
                    const SizedBox(height: 10),
                    MinimaxTreeWidget(root: controller.lastMinimaxTree!),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Nodes: ${controller.lastNodesExpanded} | Time: ${controller.lastAiTime.inMilliseconds}ms",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _buildButtons(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _modeTitle,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                _turnText,
                key: ValueKey(
                  controller.isGameOver.toString() +
                      controller.currentPlayer.toString(),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (!controller.isGameOver)
              CircleAvatar(
                radius: 10,
                backgroundColor: controller.currentPlayer == 1
                    ? Colors.red
                    : Colors.yellow,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(radius: 10, backgroundColor: Colors.red),
        const SizedBox(width: 10),
        Text(
          "${controller.scorePlayer1}",
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 30),
        const CircleAvatar(radius: 10, backgroundColor: Colors.yellow),
        const SizedBox(width: 10),
        Text(
          "${controller.scorePlayer2}",
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    return AnimatedOpacity(
      opacity: controller.isGameOver ? 0.6 : 1,
      duration: const Duration(milliseconds: 500),
      child: IgnorePointer(
        ignoring: _inputBlocked,
        child: Container(
          width: MediaQuery.of(context).size.width - 28,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: GridView.builder(
            itemCount: 42,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              int row = index ~/ 7;
              int col = index % 7;
              int cell = controller.board.grid[row][col];
              Color color;
              if (cell == 1) {
                color = Colors.red;
              } else if (cell == 2) {
                color = Colors.yellow;
              } else {
                color = const Color(0xFFE5E7EB);
              }

              return InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () async {
                  if (_inputBlocked) return;

                  setState(() => pressedIndex = null);
                  controller.makeMove(col);
                  setState(() {});

                  // Trigger AI only in single-player after the human move
                  if (widget.mode == GameMode.singlePlayer &&
                      !controller.isGameOver &&
                      controller.currentPlayer == 2) {
                    await controller.makeAiMove();
                    setState(() {});
                  }
                },
                onTapDown: (_) => setState(() => pressedIndex = index),
                onTapUp: (_) => setState(() => pressedIndex = null),
                onTapCancel: () => setState(() => pressedIndex = null),
                child: AnimatedScale(
                  scale: pressedIndex == index ? 0.85 : 1,
                  duration: const Duration(milliseconds: 100),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        if (cell != 0)
                          BoxShadow(
                            color: (cell == 1 ? Colors.red : Colors.yellow)
                                .withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AppButton(
              icon: Icons.refresh,
              label: "Play Again",
              onTap: () {
                controller.resetGame();
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: AppButton(
              icon: Icons.home,
              label: "Menu",
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
