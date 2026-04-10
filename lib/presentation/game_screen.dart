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
              Text(
                controller.winner == null
                    ? "Player ${controller.currentPlayer}'s Turn"
                    : "Player ${controller.winner} Wins !",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                          blurRadius: 10,
                          offset: Offset(0, 4),
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
                        return GestureDetector(
                          onTap: () {
                            controller.makeMove(col);
                            setState(() {});
                          },
                          child: Container(
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
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
