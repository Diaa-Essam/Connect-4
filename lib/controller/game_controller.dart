import 'package:connect_four/model/board.dart';

class GameController {
  Board board = Board();
  List<List<int>> winningCells = [];
  int currentPlayer = 1;
  int? winner;
  bool isDraw = false;

  // Should this function return boolean or void?
  bool makeMove(int column) {
    if (winner != null) return false;

    bool success = board.dropPiece(column, currentPlayer);

    if (!success) return false;

    if (success) {
      final result = board.checkWin(currentPlayer);
      if (result != null) {
        winner = currentPlayer;
        winningCells = result;
      } else if (board.isBoardFull()) {
        isDraw = true;
      }
      currentPlayer = (currentPlayer == 1) ? 2 : 1;
    }
    return true;
  }

  bool isWinnigCell(int row, int col) {
    for (List<int> list in winningCells) {
      if (list[0] == row && list[1] == col) return true;
    }
    return false;
  }

  void resetGame() {
    board = Board();
    currentPlayer = 1;
    winner = null;
    isDraw = false;
    winningCells = [];
  }
}
