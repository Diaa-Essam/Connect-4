import 'package:connect_four/model/board.dart';
import 'package:connect_four/controller/ai_controller.dart';

class GameController {
  Board board = Board();
  List<List<int>> winningCells = [];
  int currentPlayer = 1;
  int? winner;
  bool isDraw = false;
  final AiController _ai = AiController();
  bool isAiEnabled = true;

  Future<bool> makeMove(int column) async {
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
      } else {
        currentPlayer = (currentPlayer == 1) ? 2 : 1;
      }
    }
    return true;
  }

  Future<void> makeAiMove() async {
    if (!isAiEnabled || currentPlayer != 2 || winner != null || isDraw) return;
    await Future.delayed(Duration(milliseconds: 400));
    final aiCol = _ai.getBestMove(board);
    await makeMove(aiCol);
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
