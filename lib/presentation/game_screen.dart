import 'package:connect_four/controller/game_controller.dart';
import 'package:connect_four/model/game_mode.dart';
import 'package:connect_four/presentation/app_button.dart';
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
        decoration: BoxDecoration(
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
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.mode == GameMode.singlePlayer
                            ? "Single Player "
                            : "Two Players ",

                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 1000),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(width: 10),

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
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(radius: 10, backgroundColor: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "${controller.scorePlayer1}",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 30),
                      CircleAvatar(radius: 10, backgroundColor: Colors.yellow),
                      SizedBox(width: 10),
                      Text(
                        "${controller.scorePlayer2}",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  // The Board Of The Game :-:-:
                  AnimatedOpacity(
                    opacity: (controller.winner != null || controller.isDraw)
                        ? 0.6
                        : 1,
                    duration: Duration(milliseconds: 1000),
                    child: IgnorePointer(
                      ignoring: controller.winner != null || controller.isDraw,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 28,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          boxShadow: [
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
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            int row = index ~/ 7;
                            int col = index % 7;

                            int cell = controller.board.grid[row][col];
                            bool isWinnigCell = controller.isWinnigCell(
                              row,
                              col,
                            );

                            Color color;
                            if (isWinnigCell) {
                              color = Colors.green;
                            } else if (cell == 1) {
                              color = Colors.red;
                            } else if (cell == 2) {
                              color = Colors.yellow;
                            } else {
                              color = Color(0xFFE5E7EB);
                            }
                            return InkWell(
                              borderRadius: BorderRadius.circular(50),

                              onTap: () async {
                                await controller.handleTap(
                                  col,
                                  widget.mode,
                                  onMoveComplete: () => setState(() {}),
                                );
                                setState(() {});
                              },
                              child: AnimatedScale(
                                scale: pressedIndex == index ? 0.85 : 1,
                                duration: Duration(milliseconds: 100),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  margin: EdgeInsets.all(6),
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

                                      BoxShadow(
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

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        icon: Icons.refresh,
                        label: "Play Again",
                        onTap: () {
                          controller.resetGame();
                          setState(() {});
                        },
                      ),

                      SizedBox(width: 20),

                      AppButton(
                        icon: Icons.home,
                        label: "Menu",
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
