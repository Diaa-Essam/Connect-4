import 'dart:math';
import 'package:connect_four/model/board.dart';

class AiController {
  // final Random _random = Random();

  // int getBestMove(Board board) {
  //   List<int> availableColumns = [];

  //   for (int col = 0; col < board.grid[0].length; col++) {
  //     availableColumns.add(col);
  //   }
  //   return availableColumns[_random.nextInt(availableColumns.length)];
  // }

  int getBestMove(Board board) {
    int bestScore = -999999;
    int bestCol = -1;

    for (int col = 0; col < board.grid[0].length; col++) {
      if (board.grid[0][col] != 0) {
        continue;
      }

      Board tempBoard = board.clone();
      tempBoard.dropPiece(col, 2);
      int score = minimax(tempBoard, 5, false);

      if (score > bestScore) {
        bestScore = score;
        bestCol = col;
      }
    }
    return bestCol;
  }

  int minimax(Board board, int depth, bool isMaximizing) {
    if (board.checkWin(2) != null) return 1000 + depth;
    if (board.checkWin(1) != null) return -1000 - depth;
    if (board.isBoardFull() || depth == 0) return 0;

    if (isMaximizing) {
      int best = -999999;
      for (int col = 0; col < board.grid[0].length; col++) {
        if (board.grid[0][col] != 0) continue;

        Board tempBoard = board.clone();
        tempBoard.dropPiece(col, 2);
        best = max(best, minimax(board, depth - 1, false));
      }
      return best;
    } else {
      int best = 999999;
      for (int col = 0; col < board.grid[0].length; col++) {
        if (board.grid[0][col] != 0) continue;
        Board tempBoard = board.clone();
        tempBoard.dropPiece(col, 1);
        best = min(best, minimax(board, depth - 1, true));
      }
      return best;
    }
  }
}
