import 'dart:async';
import 'dart:isolate';
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

  // ── Benchmark ──────────────────────────────────────────────────────────────
  //
  // Fix 1: Run the entire game inside a separate Isolate so the heavy CPU work
  //        never blocks the Flutter UI thread (which was causing the watchdog
  //        to kill the app at high K values).
  //
  // Fix 2: The isolate entry-point (_benchmarkEntry) intentionally does NOT
  //        store result.root anywhere. At K=7 each getBestMove call can
  //        allocate ~800 K Node objects; keeping them alive via lastMinimaxTree
  //        prevented the GC from reclaiming memory between moves, eventually
  //        causing an OOM crash. Discarding the root immediately lets the GC
  //        collect each tree before the next move is computed.

  static Future<Map<String, dynamic>> runBenchmarkGame(
    Algorithm algo,
    int k,
  ) async {
    // Pack the two primitive arguments into a list — Isolate.run receives a
    // single argument, and closures that capture non-primitive objects are not
    // guaranteed to be sendable across isolate boundaries.
    return await Isolate.run(() => _benchmarkEntry([algo.index, k]));
  }

  // Isolate entry-point. Receives [algoIndex, k] as a plain List<int>.
  static Map<String, dynamic> _benchmarkEntry(List<int> args) {
    final algo = Algorithm.values[args[0]];
    final k    = args[1];

    final ctrl      = GameController(algorithm: algo, kDepth: k);
    final stopwatch = Stopwatch()..start();
    int totalNodes  = 0;
    int moves       = 0;

    while (!ctrl.isGameOver) {
      final result = ctrl.ai.getBestMove(ctrl.board, ctrl.currentPlayer);

      totalNodes += result.nodesExpanded;

      // Fix 2: do NOT assign result.root — let the tree be GC'd immediately.
      // ctrl.lastMinimaxTree = result.root; ← removed

      ctrl.makeMove(result.column);
      moves++;

      // Note: Future.delayed / await cannot be used in a synchronous isolate
      // entry-point. The Isolate itself runs on its own thread, so there is no
      // need to yield; the UI thread remains responsive automatically.
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