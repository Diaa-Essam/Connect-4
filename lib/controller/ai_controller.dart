import 'dart:math';
import 'package:connect_four/model/board.dart';

class AiController {
  final Random _random = Random();

  int getBestMove(Board board) {
    List<int> availableColumns = [];

    for (int col = 0; col < board.grid[0].length; col++) {
      availableColumns.add(col);
    }
    return availableColumns[_random.nextInt(availableColumns.length)];
  }
}
