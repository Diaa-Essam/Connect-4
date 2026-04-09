import 'package:connect_four/controller/game_controller.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  final GameController controller = GameController();
  GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        itemCount: 42,
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
            color = Colors.grey;
          }
          return Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          );
        },
      ),
    );
  }
}
