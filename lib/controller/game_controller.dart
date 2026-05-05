import 'package:connect_four/core/app_constants.dart';
import 'package:connect_four/model/board.dart';
import 'package:connect_four/controller/ai_controller.dart';
import 'package:connect_four/model/game_mode.dart';
import 'package:flutter/material.dart';

class GameController {
  Board board = Board();
  List<List<int>> winningCells = [];
  int currentPlayer = 1;
  int? winner;
  bool isDraw = false;
  final AiController _ai = AiController();
  bool isAiEnabled = true;
  int scorePlayer1 = 0;
  int scorePlayer2 = 0;

  Future<void> handleTap(
    int col,
    GameMode mode, {
    VoidCallback? onMoveComplete,
  }) async {
    if (winner != null || isDraw) return;
    if (mode == GameMode.singlePlayer && currentPlayer != 1) return;

    await makeMove(col);
    onMoveComplete?.call();

    if (mode == GameMode.singlePlayer && winner == null && !isDraw) {
      await Future.delayed(AppConstants.aiMoveDelay);
      await makeAiMove();
    }
  }

  bool makeMove(int column) {
    if (winner != null) return false;

    bool success = board.dropPiece(column, currentPlayer);

    if (!success) return false;

    final result = board.checkWin(currentPlayer);
    if (result != null) {
      winner = currentPlayer;
      winningCells = result;
      if (currentPlayer == 1) {
        scorePlayer1++;
      } else {
        scorePlayer2++;
      }
    } else if (board.isBoardFull()) {
      isDraw = true;
    } else {
      currentPlayer = (currentPlayer == 1) ? 2 : 1;
    }

    return true;
  }

  Future<void> makeAiMove() async {
    if (!isAiEnabled || currentPlayer != 2 || winner != null || isDraw) return;
    await Future.delayed(Duration(milliseconds: 300));
    final aiCol = _ai.getBestMove(board);
    makeMove(aiCol);
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
