import 'package:connect_four/controller/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController controller = GameController();

  int? pressedIndex;

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
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.isDraw
                          ? "DRAW"
                          : controller.winner == null
                          ? "TURN"
                          : "WINNER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
                SizedBox(height: 10),

                Expanded(
                  child: AspectRatio(
                    aspectRatio: 7 / 6,
                    child: Container(
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
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                        ),
                        itemBuilder: (context, index) {
                          int row = index ~/ 7;
                          int col = index % 7;

                          int cell = controller.board.grid[row][col];
                          bool isWinnigCell = controller.isWinnigCell(row, col);

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
                              if (controller.currentPlayer != 1) return;
                              await controller.makeMove(col);
                              setState(() {});
                              await controller.makeAiMove();
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
                              duration: Duration(milliseconds: 100),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                margin: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  boxShadow: [
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

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Play Again",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    controller.resetGame();
                    setState(() {});
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
