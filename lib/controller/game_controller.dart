import 'package:connect_four/model/board.dart';

class GameController {
  Board board = Board();
  int currentPlayer = 1;

  void makeMove(int column) {
    bool success = board.dropPiece(column, currentPlayer);

    if (success) {
      if (board.checkWin(currentPlayer)) {
        print("Plyer $currentPlayer wins!");
      }
      currentPlayer = (currentPlayer == 1) ? 2 : 1;
    }
  }
}
