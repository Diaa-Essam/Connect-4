import 'dart:async';
import 'package:connect_four/controller/ai_controller.dart';
import 'package:connect_four/model/algorithm.dart';
import 'package:connect_four/model/board.dart';
import 'package:connect_four/model/node.dart';

class GameController {
  Board board = Board();
  int currentPlayer = 1; // 1 = human (red), 2 = AI (yellow)
  bool isGameOver = false;
  
  // Scoring: total connections on board until full
  int scorePlayer1 = 0;
  int scorePlayer2 = 0;

  final Algorithm algorithm;
  final int kDepth;
  late AiController ai;

  Node? lastMinimaxTree;
  int lastNodesExpanded = 0;
  Duration lastAiTime = Duration.zero;

  // For AI vs AI benchmark
  List<Map<String, dynamic>> benchmarkResults = [];

  GameController({required this.algorithm, required this.kDepth}) {
    ai = AiController(algorithm: algorithm, maxDepth: kDepth);
  }

  bool makeMove(int column) {
    if (isGameOver) return false;
    bool success = board.dropPiece(column, currentPlayer);
    if (!success) return false;

    // Recalculate total connections on entire board
    scorePlayer1 = board.countAllConnections(1);
    scorePlayer2 = board.countAllConnections(2);

    if (board.isBoardFull()) {
      isGameOver = true;
    } else {
      currentPlayer = (currentPlayer == 1) ? 2 : 1;
    }
    return true;
  }

  Future<void> makeAiMove() async {
    if (isGameOver) return;
    await Future.delayed(const Duration(milliseconds: 300)); // visual delay

    final result = ai.getBestMove(board, currentPlayer);
    lastMinimaxTree = result.root;
    lastNodesExpanded = result.nodesExpanded;
    lastAiTime = result.elapsedTime;

    // Print tree to console as required
    print("=== MINIMAX TREE (Player $currentPlayer | ${algorithm.name}) ===");
    AiController.printTree(result.root);
    print("Nodes expanded: ${result.nodesExpanded}");
    print("Time taken: ${result.elapsedTime}");
    print("=====================================");

    makeMove(result.column);
  }

  // For background benchmark: run entire game without UI delays
  static Future<Map<String, dynamic>> runBenchmarkGame(
    Algorithm algo,
    int k,
  ) async {
    final ctrl = GameController(algorithm: algo, kDepth: k);
    final stopwatch = Stopwatch()..start();
    int totalNodes = 0;
    int moves = 0;

    while (!ctrl.isGameOver) {
      final result = ctrl.ai.getBestMove(ctrl.board, ctrl.currentPlayer);
      totalNodes += result.nodesExpanded;
      ctrl.lastMinimaxTree = result.root;
      ctrl.makeMove(result.column);
      moves++;
    }

    stopwatch.stop();
    return {
      'algorithm': algo.name,
      'k': k,
      'timeMs': stopwatch.elapsedMilliseconds,
      'totalNodes': totalNodes,
      'moves': moves,
      'score1': ctrl.scorePlayer1,
      'score2': ctrl.scorePlayer2,
    };
  }

  void resetGame() {
    board = Board();
    currentPlayer = 1;
    isGameOver = false;
    scorePlayer1 = 0;
    scorePlayer2 = 0;
    lastMinimaxTree = null;
    lastNodesExpanded = 0;
    lastAiTime = Duration.zero;
  }
}