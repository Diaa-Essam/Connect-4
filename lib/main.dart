import 'package:flutter/material.dart';
import 'model/Board.dart';

void main() {
  Board board = Board();
  board.dropPiece(1, 1);
  board.printBoard();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}
