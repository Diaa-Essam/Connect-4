import 'package:flutter/material.dart';
import 'model/Board.dart';

void main() {
  Board board = Board();
  board.dropPiece(1, 1);
  board.grid[0][0] = 1;
  board.grid[0][1] = 1;
  board.grid[0][2] = 1;
  board.grid[0][3] = 1;
  board.printBoard();
  print(board.checkHorizontalWin(1));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}
