import 'package:connect_four/model/board.dart';

class GameController {
  Board board = Board();
  int currentPlayer = 1;
  int? winner;
  bool isDraw = false;

  // Should this function return boolean or void?
  bool makeMove(int column) {
    if (winner != null) return false;

    bool success = board.dropPiece(column, currentPlayer);

    if (!success) return false;

    if (success) {
      if (board.checkWin(currentPlayer)) {
        winner = currentPlayer;
      } else if (board.isBoardFull()) {
        isDraw = true;
      }
      currentPlayer = (currentPlayer == 1) ? 2 : 1;
    }
    return true;
  }

  void resetGame() {
    board = Board();
    currentPlayer = 1;
    winner = null;
    isDraw = false;
  }
}
