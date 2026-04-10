import 'dart:math';

import 'package:connect_four/model/board.dart';

class GameController {
  Board board = Board();
  int currentPlayer = 1;
  int? winner;

  // Should this function return boolean or void?
  bool makeMove(int column) {
    if (winner != null) return false;

    bool success = board.dropPiece(column, currentPlayer);

    if (!success) return false;

    if (success) {
      if (board.checkWin(currentPlayer)) {
        winner = currentPlayer;
      }
      currentPlayer = (currentPlayer == 1) ? 2 : 1;
    }
    return true;
  }

  void resetGame() {
    board = Board();
    currentPlayer = 1;
    winner = null;
  }

  //1217. Minimum Cost to Move Chips to The Same Position
  int minCostToMoveChips(List<int> position) {
    int even = 0, odd = 0;
    for (int val in position) {
      if (val % 2 == 0) {
        even++;
      } else {
        odd++;
      }
    }
    return min(even, odd);
  }

  //136. Single Number
  int singleNumber(List<int> nums) {
    int result = 0;
    for (int num in nums) {
      result ^= num;
    }
    return result;
  }
}
