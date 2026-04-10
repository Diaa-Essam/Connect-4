import 'package:connect_four/model/board.dart';

class GameController {
  Board board = Board();
  int currentPlayer = 1;
  int? winner;

  bool makeMove(int column) {
    bool success = board.dropPiece(column, currentPlayer);

    if (!success) return false;

    if (success) {
      if (board.checkWin(currentPlayer)) {
        print("Player $currentPlayer wins!");
        winner = currentPlayer;
      }
      currentPlayer = (currentPlayer == 1) ? 2 : 1;
    }
    return true;
  }
}
