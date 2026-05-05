import 'package:connect_four/controller/game_controller.dart';
import 'package:connect_four/model/game_mode.dart';
import 'package:connect_four/presentation/app_button.dart';
import 'package:connect_four/presentation/min_max_tree.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  const GameScreen({super.key, required this.mode});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController controller = GameController();

  int? pressedIndex;
  int? droppingColumn;

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
                  // ── Status header ──
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.mode == GameMode.singlePlayer
                            ? "Single Player"
                            : "Two Players",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 1000),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: Text(
                              controller.isDraw
                                  ? "DRAW"
                                  : controller.winner != null
                                  ? "WINNER"
                                  : widget.mode == GameMode.singlePlayer
                                  ? (controller.currentPlayer == 1
                                        ? "PLAYER"
                                        : "AI Thinking...")
                                  : (controller.currentPlayer == 2
                                        ? "PLAYER 1"
                                        : "PLAYER 2"),
                              key: ValueKey(
                                controller.currentPlayer.toString() +
                                    controller.winner.toString() +
                                    controller.isDraw.toString(),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (!controller.isDraw)
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: controller.winner != null
                                  ? controller.winner == 1
                                        ? Colors.red
                                        : Colors.yellow
                                  : controller.currentPlayer == 1
                                  ? Colors.red
                                  : Colors.yellow,
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ── Score row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                      ),
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
                      const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.yellow,
                      ),
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
                  ),
                  const SizedBox(height: 10),
                  // ── Board ──
                  AnimatedOpacity(
                    opacity: (controller.winner != null || controller.isDraw)
                        ? 0.6
                        : 1,
                    duration: const Duration(milliseconds: 1000),
                    child: IgnorePointer(
                      ignoring: controller.winner != null || controller.isDraw,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 28,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 5),
                            ),
                          ],
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: GridView.builder(
                          itemCount: 42,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            int row = index ~/ 7;
                            int col = index % 7;
                            int cell = controller.board.grid[row][col];
                            bool isWinCell = controller.isWinnigCell(row, col);

                            Color color;
                            if (isWinCell) {
                              color = Colors.green;
                            } else if (cell == 1) {
                              color = Colors.red;
                            } else if (cell == 2) {
                              color = Colors.yellow;
                            } else {
                              color = const Color(0xFFE5E7EB);
                            }

                            return InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () async {
                                if (widget.mode == GameMode.singlePlayer &&
                                    controller.currentPlayer != 1)
                                  return;

                                setState(() {
                                  pressedIndex = null;
                                  droppingColumn = col;
                                });

                                await controller.makeMove(col);
                                setState(() {});

                                if (GameMode.singlePlayer == widget.mode) {
                                  await Future.delayed(
                                    Duration(milliseconds: 500),
                                  );
                                  await controller.makeAiMove();
                                }
                                setState(() {});
                              },
                              onTapDown: (_) {
                                setState(() {
                                  pressedIndex = index;
                                });
                              },
                              onTapUp: (_) {
                                setState(() {
                                  pressedIndex = null;
                                });
                              },
                              onTapCancel: () {
                                setState(() {
                                  pressedIndex = null;
                                });
                              },
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
                                          color:
                                              (cell == 1
                                                      ? Colors.red
                                                      : Colors.yellow)
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
                  ),
                  // ── Minimax tree (single player only) ──
                  if (widget.mode == GameMode.singlePlayer &&
                      controller.lastMinimaxTree != null)
                    MinimaxTreeWidget(root: controller.lastMinimaxTree!),

                  const SizedBox(height: 10),
                  // ── Buttons ──
                  Padding(
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
}
