import 'package:connect_four/controller/game_controller.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController controller = GameController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.winner == null ? "Turn: " : "Winner: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 12,
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
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
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

                        Color color;
                        if (cell == 1) {
                          color = Colors.red;
                        } else if (cell == 2) {
                          color = Colors.yellow;
                        } else {
                          color = Colors.white;
                        }
                        return InkWell(
                          borderRadius: BorderRadius.circular(50),

                          onTap: () {
                            controller.makeMove(col);
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
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
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text("Reset Game"),
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
    );
  }
}
